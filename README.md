# Terraform AWS VPC & NAT Gateway

一個用於創建 AWS VPC 和 NAT Gateway 的 Terraform 專案。

## 架構圖
![Architecture](docs/terraform-aws-ec2-example.drawio.png)

本專案設計了一個典型的 AWS 網路架構：

- **Public Subnet** - 包含可直接訪問網際網路的資源
  - Public EC2 Instance 可從外部直接通過 SSH 連接
  - 流量通過 Internet Gateway 進出
  
- **Private Subnet** - 包含不需要直接網際網路訪問的資源
  - Private EC2 Instance 只能透過 Bastion (Public Instance) 連接
  - 出站網際網路流量通過 NAT Gateway 進行 (對外隱藏真實 IP)
  - 無法從外部直接連接

## 快速開始

### 前置條件

- 安裝 [Terraform](https://www.terraform.io/)
- 配置 [AWS CLI Profile](https://docs.aws.amazon.com/zh_tw/cli/v1/userguide/cli-configure-files.html#cli-configure-files-format-profile) 
- 生成 SSH Key

### AWS Key Pair 生成

本項目使用本地生成的 SSH public key 上傳至 AWS。如果還沒有 SSH Key，請執行以下命令生成：

```bash
# 生成新的 SSH Key 如果已有可跳過）
ssh-keygen -t ed25519 -f ~/.ssh/terraform-ec2

# 查看生成的 public key
cat ~/.ssh/terraform-ec2.pub
```

**說明：**
- `~/.ssh/terraform-ec2` - private key 檔案（保管好，用於登入 EC2）
- `~/.ssh/terraform-ec2.pub` - public key 檔案（將用於在 AWS 中建立 Key Pair）
- Terraform 會自動將 public key 上傳到 AWS 建立 Key Pair


### 使用步驟

1. **複製範例配置文件**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **修改 terraform.tfvars** 配置你的設定
   ```bash
   vim terraform.tfvars
   ```

3. **初始化 Terraform**
   ```bash
   terraform init
   ```

4. **檢查執行計劃**
   ```bash
   terraform plan
   ```

5. **應用配置**
   ```bash
   terraform apply
   ```

6. **查看輸出結果** - 在 console 中會顯示 `instance_public_ip`、`instance_private_ip` 和 SSH 登入命令

7. **從 console 輸出中複製 SSH 命令並連接**
   
   連接 Public Instance：
   ```bash
   # 複製 console 中的 ssh_command 並執行
   ssh -i ~/.ssh/terraform-ec2 ec2-user@<public-instance-ip>
   ```
   
   連接 Private Instance (透過 Bastion)：
   ```bash
   # 複製 console 中的 ssh_command_via_bastion 並執行
   ssh -o "ProxyCommand=ssh -i ~/.ssh/terraform-ec2 -W %h:%p ec2-user@<public-ip>" -i ~/.ssh/terraform-ec2 ec2-user@<private-ip>
   ```

8. **銷毀此設定檔配置的所有資源**
   ```bash
   terraform destroy
   ```

## 項目結構

```text
.
├── .gitignore                 # Git 忽略文件配置
├── .terraform.lock.hcl        # Terraform 鎖定 provider 版本的檔案
├── docs/                      # 專案文件目錄 (包含架構圖)
├── providers.tf               # Terraform 配置和 Data Sources
├── network.tf                 # VPC、Subnet、Internet Gateway、NAT Gateway、Route Table
├── security.tf                # Key Pair、Security Group
├── compute.tf                 # EC2 Instance
├── outputs.tf                 # Output 定義
├── variables.tf               # 變數定義
├── terraform.tfvars.example   # 變數值範例文件
├── README.md                  # 專案說明文件
└── terraform.tfstate*         # Terraform 狀態文件 (不會提交到 Git)
```

## 資源說明

### 網路層
- **VPC** - 自定義虛擬私有雲
- **Public Subnet** - 位於第一個可用區 (10.0.0.0/20)
- **Private Subnet** - 位於第二個可用區 (10.0.16.0/20)
- **Internet Gateway** - 提供 Public Subnet 連接到網際網路
- **NAT Gateway** - 提供 Private Instance 連接到網際網路 (使用 Elastic IP)
- **Route Table** - 分別為 Public 和 Private Subnet 設定路由規則

### 安全層
- **Key Pair** - 上傳本地 SSH public key 到 AWS
- **Security Group** - 設定防火牆規則，允許 SSH 連接

### 計算層
- **Public EC2 Instance** - 可直接從外部連接 (10.0.0.0/20 subnet)
- **Private EC2 Instance** - 只能透過 Public Instance (Bastion) 連接，但可透過 NAT Gateway 訪問網際網路

## 注意事項

- `terraform.tfstate` 包含敏感信息，已加入 `.gitignore`，不會提交到版本控制
- 確保 AWS CLI profile 正確配置（此範例使用 `admin` profile）
- public key 路徑使用 `~/.ssh/terraform-ec2.pub`，請確保該檔案存在

