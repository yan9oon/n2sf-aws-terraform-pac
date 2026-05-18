# N2SF-AWS-Terraform-PaC

N2SF 기반 금융권 클라우드 보안통제의 오픈소스 Policy-as-Code 적용 가능성을 검토하기 위한 Terraform PoC 저장소입니다.

본 저장소는 AWS Financial Services Industry Lens의 Payments 참조 아키텍처를 기반으로, N2SF 보안통제와 AWS 리소스 및 Terraform 코드 간 매핑 가능성을 확인하고, Checkov를 활용하여 일부 보안통제의 자동검증 가능성을 평가하기 위해 작성되었습니다.

> 본 프로젝트는 실제 AWS 운영환경 배포를 목적으로 하지 않습니다.  
> Terraform `validate`, Checkov 정적 분석을 통한 연구용 검증을 목적으로 합니다.

---

## 1. Project Overview

본 연구의 목적은 N2SF의 정책적 보안통제를 AWS 클라우드 리소스 설정과 Terraform 코드 수준에서 표현하고, 오픈소스 Policy-as-Code 도구인 Checkov를 통해 자동검증 가능한 항목과 한계가 있는 항목을 구분하는 것입니다.

N2SF의 C/S/O 등급은 AWS 리소스에 기본적으로 존재하는 기술적 속성이 아니므로, 본 PoC에서는 Terraform 리소스의 `tags`와 주요 설정값을 활용하여 N2SF 등급과 보안통제 항목을 표현하였습니다.

---

## 2. Research Scope

본 PoC는 AWS Payments 참조 아키텍처 전체를 완성 구현하는 것이 아니라, N2SF 보안통제와 직접 연결되고 Terraform 코드로 표현 가능한 고객 책임 영역 리소스를 중심으로 구성하였습니다.

### Included

- IAM Role / IAM Policy
- VPC
- Public Subnet / Private Subnet
- Route Table
- Security Group
- KMS
- S3 Log Bucket
- DynamoDB
- CloudTrail
- CloudWatch Log Group
- API Gateway
- AWS WAF
- GuardDuty
- AWS Config
- Secrets Manager

### Excluded

- CloudFront
- ECS Fargate
- Aurora
- CloudHSM
- OpenSearch
- Route 53
- NAT Gateway
- 실제 결제 애플리케이션 코드
- OAuth, mTLS, 고객 동의 관리 등 애플리케이션 계층 보안 기능

---

## 3. Repository Structure

```text
.
├── api_gateway_waf.tf      # API Gateway 및 WAF 설정
├── cloudtrail.tf           # CloudTrail 감사 로그 설정
├── cloudwatch.tf           # CloudWatch Log Group 설정
├── dynamodb.tf             # 결제 거래 데이터 저장소 설정
├── guardduty_config.tf     # GuardDuty 및 AWS Config 설정
├── iam.tf                  # IAM Role 및 최소권한 정책 설정
├── kms.tf                  # KMS 암호화 키 설정
├── locals.tf               # 공통 태그 및 네이밍 규칙
├── network.tf              # VPC, Subnet, Route Table 설정
├── outputs.tf              # 주요 리소스 출력값
├── s3_log_bucket.tf        # 로그 저장용 S3 Bucket 설정
├── secrets.tf              # Secrets Manager 설정
├── security_group.tf       # Security Group 설정
├── variables.tf            # 변수 정의
├── versions.tf             # Terraform 및 Provider 버전 정의
├── .gitignore
└── README.md
```

---

4. N2SF Mapping Concept

본 PoC에서는 N2SF 보안통제를 다음과 같이 AWS 리소스 및 Terraform 설정값과 연결합니다.


---

5. N2SF Tags

본 PoC는 Terraform 리소스에 공통 태그를 부여하여 N2SF 관점의 정책적 분류값을 표현합니다.

예시:

```hcl
tags = {
  Project       = "n2sf-payments-poc"
  Environment   = "research"
  ManagedBy     = "Terraform"
  ResearchScope = "N2SF-PaC-PoC"

  N2SF_Grade    = "S"
  N2SF_Service  = "Payments"
  N2SF_DataType = "PaymentTransactionData"
}
```

이 태그는 Checkov 기본 룰이 직접 해석하는 값은 아닙니다.
따라서 본 연구에서는 Checkov의 PASS/FAIL 결과를 N2SF 통제 항목에 사후 매핑하여 자동검증 가능성을 평가합니다.

---

6. Prerequisites

- Terraform
- Checkov
- Git

```bash
terraform version
checkov --version
git --version
```
Checkov 설치
```bash
pip install checkov
```

---

7. Terraform Validation

7.1 Format
```bash
terraform fmt -recursive
```bash
7.2 Init
```
```bash
terraform init
```
7.3 Validate
```bash
terraform validate
```
7.4 Plan
```bash
terraform plan -refresh=false -out=n2sf-poc.tfplan
```

**terraform apply 안함 **

---

8. Checkov Policy-as-Code Validation

Checkov를 사용하여 Terraform 코드의 보안 설정을 정적 분석합니다.
```bash
checkov -d . --framework terraform
```

JSON 결과 저장:
```bash
mkdir -p results
checkov -d . --framework terraform -o json > results/checkov-result.json
```
CLI 결과 저장:
```bash
checkov -d . --framework terraform | tee results/checkov-result.txt
```

---

9. Validation Focus

Checkov 검증 결과는 다음 항목을 중심으로 해석합니다.

- S3 Public Access Block 설정 여부
- S3 서버 측 암호화 여부
- S3 Versioning 및 Object Lock 설정 여부
- KMS Key Rotation 설정 여부
- CloudTrail 활성화 여부
- CloudTrail Log File Validation 설정 여부
- CloudWatch 로그 보존기간 설정 여부
- Security Group의 공개 포트 허용 여부
- DynamoDB 암호화 및 PITR 설정 여부
- API Gateway 접근 및 로깅 설정 여부
- GuardDuty 활성화 여부
- AWS Config 설정 여부
- Secrets Manager 암호화 여부

---

10. Research Limitation

본 PoC는 Terraform 코드와 Checkov 기본 룰을 기반으로 한 정적 검증에 초점을 둡니다. 따라서 다음 항목은 코드만으로 완전한 판단이 어렵습니다.

- 업무정보의 실제 C/S/O 등급 판단
- 조직의 위험평가 절차
- 정보보호위원회 심의 및 승인 절차
- 사고보고 및 규제기관 통보 체계
- 운영 중 구성 변경에 따른 drift 탐지
- OAuth, mTLS, 고객 동의 관리 등 애플리케이션 계층 보안
- 실제 결제 애플리케이션의 비즈니스 로직 보안

따라서 본 PoC의 결과는 “N2SF 통제 전체를 자동검증할 수 있다”는 의미가 아니라, N2SF 통제 중 Terraform 설정값과 Checkov 룰로 확인 가능한 기술적 통제 항목을 구분하기 위한 연구용 기준으로 활용됩니다.