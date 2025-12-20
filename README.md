# terraform-aws-ec2-example

一個用於創建 AWS EC2 執行個體的 Terraform 示範專案。

## 架構圖
![Architecture](docs/terraform-aws-ec2-example.drawio.png)

## 工作流程

1. **定義變數** (`variables.tf`) - 設定 AWS 區域、Key Pair、Instance 類型等參數
2. **配置資源** (`main.tf`)
   - 查詢最新的 Amazon Linux 2 AMI
   - 上傳 SSH public key 到 AWS (Key Pair)
   - 建立 Security Group (允許 SSH 連接)
   - 建立 EC2 Instance
3. **輸出結果** (`outputs`) - 顯示 Public IP 和 SSH 登入命令

## 快速開始

#### 前置條件

- 安裝 [Terraform](https://www.terraform.io/)
- 配置 [AWS CLI](https://aws.amazon.com/cli/) profile
- 生成 SSH Key

#### AWS Key Pair 生成

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


#### 使用步驟

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

6. **從 console 中複製他 output 出來的 SSH 登入命令**

7. **使用 SSH 命令登入 AWS EC2**
   ```bash
   # 執行從 console 中取得的 ssh_command
   ssh -i <key-pair-path> ec2-user@<ec2-public-ip>
   ```

## 項目結構

```text
.
├── .gitignore                 # Git 忽略文件配置
├── .terraform.lock.hcl        # Terraform 鎖定 provider 版本的檔案
├── docs/                      # 專案文件目錄 (包含架構圖)
├── main.tf                    # 主要配置文件 (定義所有資源)
├── variables.tf               # 變數定義
├── terraform.tfvars.example   # 變數值範例文件
├── README.md                  # 本專案的說明文件
└── terraform.tfstate*         # Terraform 狀態文件 (不應提交到 Git)
```

## 關鍵資源

- **AWS Key Pair** - 上傳本地 SSH public key 到 AWS
- **Security Group** - 設定防火牆規則，允許 SSH 連接
- **EC2 Instance** - 運行 Amazon Linux 2 的虛擬主機

## 注意事項

- `terraform.tfstate` 包含敏感信息，已加入 `.gitignore`，不會提交到版本控制
- 確保 AWS CLI profile 正確配置（此範例使用 `admin` profile）
- public key 路徑使用 `~/.ssh/terraform-ec2.pub`，請確保該檔案存在
