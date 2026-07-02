# AUY1105 — Grupo 4 — Evaluación Parcial 2

Repositorio principal de la **Evaluación Parcial 2** del curso AUY1105 (Infraestructura como Código II). Orquesta tres módulos Terraform reutilizables alojados en el repositorio [`Modulos-AUY1105-Grupo-4`](https://github.com/AUY1105-II/Modulos-AUY1105-Grupo-4):

- **vpc** — VPC, subnets (públicas y privadas), Internet Gateway, route table y security group SSH.
- **ec2** — Instancia EC2 `t2.micro` en subnet pública.
- **s3** — Bucket S3.

## Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│ AUY1105-Grupo-4 (root module)                           │
│                                                         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │
│  │ module.vpc  │───▶│ module.ec2  │    │ module.s3   │ │
│  └─────────────┘    └─────────────┘    └─────────────┘ │
│         ▲                  ▲                            │
│         │                  │                            │
│    Git source         Git source                        │
│  (Modulos-AUY1105-Grupo-4 @ v1.0.0)                     │
└─────────────────────────────────────────────────────────┘
```

## Variables

| Variable | Tipo | Descripción |
|---|---|---|
| `project_name` | `string` | Prefijo de nombres (default `cheese-factory`). |
| `environment` | `string` | Entorno (default `dev`). |
| `my_ip` | `string` | CIDR autorizado para SSH (ej. `203.0.113.10/32`). Sin default, obligatoria. |
| `bucket_name` | `string` | Nombre global único del bucket S3. Sin default, obligatoria. |

## Outputs

| Output | Origen | Descripción |
|---|---|---|
| `vpc_id` | `module.vpc` | ID de la VPC. |
| `subnet_ids` | `module.vpc` | IDs de subnets (públicas + privadas). |
| `instance_id` | `module.ec2` | ID de la instancia EC2. |
| `instance_ip` | `module.ec2` | IP pública de la EC2. |
| `bucket_name` | `module.s3` | Nombre del bucket S3. |

## Uso local

```bash
cp terraform.tfvars.example terraform.tfvars
# editar terraform.tfvars con tu IP/32 y un bucket_name único globalmente

terraform init
terraform validate
terraform plan
terraform apply
terraform destroy   # al terminar, para evitar costos
```

> En `main.tf` los módulos se referencian temporalmente con `?ref=main` mientras no exista el tag `v1.0.0`. Tras publicar la versión estable, actualizar los tres `source` a `?ref=v1.0.0`.

## Validaciones automáticas (CI)

El workflow `.github/workflows/iac-pr.yml` corre en cada Pull Request hacia `main` y ejecuta:

1. `terraform fmt -check -recursive`
2. `terraform init -backend=false`
3. **TFLint**
4. **Checkov** (con exclusiones documentadas en el workflow)
5. `terraform validate`
6. **OPA** (`opa test policies/`)

## Versionado

Los releases del repo principal y de los módulos se gestionan automáticamente con **release-please** (GitHub Action de Google).

- `feat:` → bump MINOR
- `fix:` → bump PATCH
- `feat!:` o `BREAKING CHANGE:` → bump MAJOR
- `chore:`, `docs:`, `refactor:` → no generan release

El `CHANGELOG.md` y los tags/releases en GitHub se crean automáticamente; **no editar a mano**.

## Estructura del repositorio

```
├── .github/workflows/
│   ├── iac-pr.yml             # CI: fmt, init, tflint, checkov, validate, opa
│   └── release-please.yml     # Release automation
├── policies/                  # OPA Rego policies
├── main.tf                    # Orquestación de los 3 módulos
├── variables.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars.example
├── release-please-config.json
└── .release-please-manifest.json
```
