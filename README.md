# The AWS Cloud Resume Challenge

This is the repo for my AWS-hosted resume website, created for the [Cloud Resume Challenge](https://cloudresumechallenge.dev/). This project was created to demonstrate competency with fundamental skills in Cloud Engineering and DevOps practices. Check out my resume at [gagelara.com](https://gagelara.com) and read about my experience with the project [over on my blog](https://blog.gagelara.com/post/the-cloud-resume-challenge/).

## Tools & Services:
- CI/CD: Github Actions.
- Infrastructure as Code: Terraform.
- Serverless: AWS Lambda, Amazon API Gateway, Amazon DynamoDB.
- Static Website: HTML, CSS, JavaScript built with [Hugo](https://gohugo.io/) using a modified version of the [Sada theme](https://github.com/darshanbaral/sada).
- Development Environment: NixOS, with a custom nix-shell.

## Architecture
![Architecture Diagram](diagram.png)


```
▸ .github/ 
  └─ workflows/
  │   ├─ deploy-frontend.yml (Build Website, Push Artifact to S3, Invalidate CloudFront Cache)
  │   └─ deploy-infra.yml (Applys terraform configuration)
▸ frontend/ (Website code, built from a modified Hugo theme)
▸ infra/ 
  ├─ bootstrap/ (Automated Deployment of the tfstate backend)
  ├─ prod/ (Terraform configuration of AWS Resources)
  │   ├─ main.tf 
  │   ├─ modules.tf  
  │   └─ modules/
  │      ├─ core/ (Core resources)
  │      └─ visitor-counter/ (API, DynamoDB, Lambda & Python files for visitor counter)
▸ flake.nix (Configures nix-shell with project-specific development resources)
```
