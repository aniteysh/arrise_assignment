# Terraform AWS Assignment Notes

## Task 1 — Multi-Instance EC2 Provisioning

Five EC2 instances are driven from a single `instances` input variable.

Each instance can independently define:

- Instance type
- AMI
- Key pair
- Root volume type
- Root volume size
- Environment
- Owner
- Whether destruction should be prevented

The configuration uses `for_each`, so there are no five manually duplicated EC2 resource blocks.

One instance uses `io1` storage:

    app-03

The instances are tagged with:

    Name
    Environment
    Owner

### Protected instance

`app-03` has:

    lifecycle {
      prevent_destroy = true
    }

It was selected because it represents the database/stateful workload in this example. Accidentally destroying it would have a higher impact than destroying a normal application instance.

Terraform will refuse to destroy this resource unless the lifecycle protection is deliberately removed from the configuration.


## Task 2 — Remote State and Locking

Previously, Terraform would use local state if no backend was configured.

For example:

    terraform.tfstate

If two people run `terraform apply` at the same time using the same local state independently, both Terraform processes can work from stale/inconsistent state.

This can result in concurrent changes, state conflicts, or one process overwriting state information produced by another process.

The S3 backend stores the shared Terraform state centrally.

The DynamoDB table provides state locking.

When one Terraform operation acquires the lock, another Terraform operation attempting to modify the same state must wait/fail rather than modifying the state concurrently.

The backend also enables encrypted remote state storage.

The S3 bucket and DynamoDB table must exist before `terraform init`.


## Task 3 — Multi-Account IAM and Cross-Account Access

### Account A

Account ID:

    000000000000

Users:

    engine
    ci
    opsadmin
    developer

Groups:

    group1
    group2

group1 contains:

    engine
    ci

group2 contains:

    opsadmin
    developer


### group1

The `engine` and `ci` users are intended for programmatic access.

They do not receive console passwords in this configuration.

They receive access keys because the assignment specifically requires CLI/programmatic users.


### Would I actually give engine and ci IAM users with access keys in production?

Generally, I would avoid long-lived IAM user access keys for CI/CD and human automation where AWS IAM roles or federated identities can be used.

For CI/CD, I would prefer short-lived credentials obtained by assuming an IAM role, for example through OIDC federation from the CI platform.

For humans, I would prefer federation/SSO and temporary credentials rather than permanent IAM user access keys.

The assignment uses IAM users and access keys because it explicitly requires `engine` and `ci` IAM users.


### roleA

roleA has administrative permissions across AWS services except IAM.

The policy allows:

    *

and explicitly denies:

    iam:*

The explicit deny ensures IAM permissions are not available through this role.


### roleB

roleB has only:

    sts:AssumeRole

and its only permitted target is:

    arn:aws:iam::111111111111:role/roleC

Therefore roleB cannot directly perform S3, EC2, ECS, or other AWS operations.


### Account B / roleC

Account B:

    111111111111

roleC has full S3 permissions only against:

    my-build-artifacts-bucket

Its trust policy allows only:

    arn:aws:iam::000000000000:role/roleB

to assume it.


### Why trust roleB specifically instead of Account A root?

Trusting:

    arn:aws:iam::000000000000:root

would establish trust with the Account A account principal rather than restricting the trust relationship to the specific roleB principal.

That is a broader trust boundary.

Trusting:

    arn:aws:iam::000000000000:role/roleB

makes the intended delegation explicit: roleC can be assumed through roleB.

This is especially important for least privilege because other identities in Account A should not automatically gain the ability to assume roleC simply because they exist in the trusted account.

The roleB trust policy is separately restricted to the specific `engine` and `ci` users in this implementation.


## Task 4 — Least-Privilege CI Policy

The `ci` user receives a custom policy rather than a broad managed policy such as `PowerUserAccess`.

The policy permits only the operations required by the stated CI workflow.

### ECR

Allowed:

    ecr:GetAuthorizationToken
    ecr:BatchCheckLayerAvailability
    ecr:CompleteLayerUpload
    ecr:InitiateLayerUpload
    ecr:PutImage
    ecr:UploadLayerPart

Repository access is restricted to:

    my-app

`ecr:GetAuthorizationToken` uses `Resource = "*"` because AWS does not support repository-level resource permissions for this action.


### ECS

The policy allows registering and describing task definitions and updating/describing the specific ECS service.

It does not grant general ECS administrative permissions such as:

    ecs:CreateCluster
    ecs:DeleteCluster
    ecs:DeleteService
    ecs:UpdateCluster
    ecs:ExecuteCommand

The service ARN is explicitly scoped to:

    my-cluster/my-service


### IAM PassRole

The CI user can pass only:

    ecsTaskExecutionRole
    ecsTaskRole

It cannot pass arbitrary IAM roles.

This is important because unrestricted `iam:PassRole` can allow a CI identity to indirectly obtain much broader AWS permissions.


### S3

The CI pipeline receives read-only access to the build-artifact bucket.

Allowed:

    s3:GetObject
    s3:GetObjectVersion
    s3:ListBucket

It does not receive:

    s3:PutObject
    s3:DeleteObject
    s3:DeleteBucket
    s3:PutBucketPolicy

Therefore the CI pipeline can consume build artifacts but cannot modify or delete them.


## Terraform Commands

Initialize:

    terraform init

Format:

    terraform fmt -recursive

Validate:

    terraform validate

Review changes:

    terraform plan

Apply:

    terraform apply

View outputs:

    terraform output


## Backend Initialization

Because the backend is configured in `backend.tf`, Terraform will initialize the S3 backend during:

    terraform init

If the backend configuration changes later:

    terraform init -reconfigure


## Important Values to Replace

Before running this configuration, replace:

    ami-0123456789abcdef0

with a valid AMI ID.

Replace the example key pair names:

    app-key
    app-key-2
    app-key-3
    app-key-4
    app-key-5

with existing EC2 key pairs.

Replace:

    my-terraform-state-bucket

with the actual Terraform state bucket.

Replace:

    my-build-artifacts-bucket

with the actual S3 artifact bucket.

Replace the example ECR repository:

    my-app

with the actual ECR repository.

Replace the example ECS cluster/service and IAM role names with the actual deployment resources if required.

The AWS account IDs remain:

    Account A = 000000000000
    Account B = 111111111111