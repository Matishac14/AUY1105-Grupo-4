# Evaluación Parcial 3 — Gestión avanzada de estado en Terraform (EV3)
Este documento resume el desarrollo completo de la Evaluación Parcial 3 del curso AUY1105 — Infraestructura como Código II, centrada en la manipulación avanzada del estado de Terraform (terraform.tfstate) y el uso de comandos como import, refresh, taint y state rm sobre una infraestructura existente en AWS.

Todas las evidencias visuales se encuentran en la carpeta img/ev3, numeradas en el orden cronológico de ejecución.

## Infraestructura inicial desplegada
La evaluación parte de una infraestructura base en AWS (desplegada usando los módulos Terraform del curso):

VPC con subnets públicas y privadas.

- Internet Gateway y tablas de ruteo asociadas.

- Instancia EC2 t2.micro.

- Security Group con reglas de entrada y salida.

- Bucket S3 para almacenamiento.

## Despliegue inicial con Terraform
#### Inicialización del proyecto Terraform:

Evidencia: ![Terraform Init](img/ev3/01_Terraform_Init.png)

#### Plan de ejecución de la infraestructura:

Evidencia: ![Terraform Plan](img/ev3/02_Terraform_Plan.png)

#### Aplicación del plan y creación de recursos:

Evidencias: 
![Terraform Apply](img/ev3/03_Terraform_Apply_01.png)
![Terraform Apply](img/ev3/04_Terraform_Apply_02.png)

#### Revisión de outputs para confirmar IDs y datos clave:

Evidencia: ![Terraform Outputs](img/ev3/05_Terraform_Outputs.png)

### Validación en la consola de AWS de cada recurso:

#### Bucket S3: ![06_Validación_S3.png](img/ev3/06_Validacion_S3.png)

#### VPC: ![AWS GUI VPC](img/ev3/07_Validacion_VPC.png)

#### Subnets: ![08_Validación_Subnet.png](img/ev3/08_Validacion_Subnet.png)

#### Route Tables: ![Terraform Init](img/ev3/09_Validacion_Route_Tables.png)

#### Asociaciones de subnets a tablas de ruteo: ![Terraform Init](img/ev3/10_Validacion_Route_Tables_Subnet_Associations.png)

#### Internet Gateway: ![Terraform Init](img/ev3/11_Validacion_Internet_Gateway.png)

#### Instancia EC2: ![Terraform Init](img/ev3/12_Validacion_Instancia.png)

#### Reglas de outbound del SG: ![Terraform Init](img/ev3/13_Validacion_Security_Group_Outbound_Rules.png)

#### Reglas de inbound del SG: ![Terraform Init](img/ev3/14_Validacion_Security_Group_Inbound_Rules.png)

## Escenario 1 — Recuperación del estado perdido (terraform state import)
En este escenario se simula la pérdida del archivo terraform.tfstate y se reconstruye el estado importando cada recurso existente en AWS.

1. Detección del problema tras la pérdida de tfstate
   Se renombra el archivo de estado a terraform.tfstate.backup y se ejecuta terraform plan, observando que Terraform propone recrear toda la infraestructura, evidenciando la desincronización.

Evidencias:

#### Cambios en el estado:
![Terraform Init](img/ev3/15_Validacion_Cambio_Tfstate.png)


#### Plan posterior a la pérdida de tfstate: ![Terraform Init](img/ev3/16_Terraform_Plan_Posterior_Perdida_Tfstate.png)

2. Importación de recursos al estado
   Se realiza terraform state import para cada recurso existente:

#### Primer intento fallido de importación del bucket S3 (error por referencia a subnet no disponible en main.tf):

Evidencia: ![Terraform Init](img/ev3/17_Importar_S3_Tfstate_error.png)

#### Corrección de la configuración en main.tf para que Terraform conozca las subnets:

Evidencia: ![Terraform Init](img/ev3/18_Correccion_Main_Para_Encontrar_Subnet.png)

#### Importaciones exitosas:

#### S3: ![Terraform Init](img/ev3/19_Importar_S3_Tfstate_OK.png)

#### VPC: ![Terraform Init](img/ev3/20_Importar_VPC_Tfstate_OK.png)

#### EC2: ![Terraform Init](img/ev3/21_Importar_EC2_Tfstate_OK.png)

#### Internet Gateway: ![Terraform Init](img/ev3/22_Importar_Internet_Gateway_Tfstate_OK.png)

#### Security Group: ![Terraform Init](img/ev3/23_Importar_Security_Group_Tfstate_OK.png)

#### Route Table: ![Terraform Init](img/ev3/24_Importar_Route_Table_Tfstate_OK.png)

#### Subnets públicas 1–3: ![Terraform Init](img/ev3/25_Importar_Subnet_Public_1_Tfstate_OK.png), ![Terraform Init](img/ev3/26_Importar_Subnet_Public_2_Tfstate_OK.png), ![Terraform Init](img/ev3/27_Importar_Subnet_Public_3_Tfstate_OK.png).


### Asociaciones de tablas de ruteo con subnets públicas: ![Terraform Init](img/ev3/31_Importar_Route_Table_Association_Subnet_Public_1_Tfstate_OK.png), ![Terraform Init](img/ev3/32_Importar_Route_Table_Association_Subnet_Public_2_Tfstate_OK.png), ![Terraform Init](img/ev3/33_Importar_Route_Table_Association_Subnet_Public_3_Tfstate_OK.png).

3. Verificación de estado y plan sin cambios
   Listado de recursos en el estado con terraform state list:

Evidencia: ![Terraform Init](img/ev3/34_Terraform_State_List.png)

#### Ejecución de terraform plan confirmando que no hay cambios pendientes:

Evidencia: ![Terraform Init](img/ev3/35_Terraform_Plan_No_Changes.png)

## Escenario 2 — Actualización y reforzamiento de recursos (refresh y taint)
En este escenario se introducen cambios manuales en la infraestructura y se sincroniza el estado con terraform refresh, para luego marcar recursos para recreación con terraform taint.

1. Cambios manuales en el Security Group
   Modificación de reglas inbound del SG desde la consola AWS (por ejemplo, apertura del puerto 8080):

Evidencia: ![Terraform Init](img/ev3/36_Modificacion_Security_Group_GUI_Puerto_8080.png)

Plan de Terraform detectando 1 cambio:

Evidencias: ![Terraform Init](img/ev3/37_Terraform_Plan_1_Change.png), ![Terraform Init](img/ev3/38_Terraform_Plan_1_Change_Detalle.png)

2. Sincronización del estado con terraform refresh
   Ejecución de terraform refresh para actualizar el tfstate con los valores reales de la infraestructura:

Evidencia: ![Terraform Init](img/ev3/39_Terraform_Refresh.png)

Nuevos planes después del refresh, verificando que las inconsistencias se reducen o se alinean:

Evidencias: ![Terraform Init](img/ev3/40_Terraform_Plan_post_Refresh.png), ![Terraform Init](img/ev3/41_Terraform_Plan_post_Refresh_2.png)

3. Reforzamiento de la instancia EC2 con terraform taint
   Marcado de la instancia EC2 para recreación:

Evidencias: ![Terraform Init](img/ev3/46_Terraform_taint_EC2_Instance.png), ![Terraform Init](img/ev3/44_Terraform_taint_EC2_Instance_Detalle_1.png), ![Terraform Init](img/ev3/46_Terraform_taint_EC2_Instance_Detalle_2.png).

Plan posterior al taint, mostrando destrucción y recreación de la instancia:

Evidencia: ![Terraform Init](img/ev3/42_Terraform_Plan_Post_Taint.png)

Aplicación de los cambios con terraform apply y recreación de la instancia:

Evidencia: ![Terraform Init](img/ev3/44_Terraform_Apply_post_Taint.png)

Outputs y estado tras la recreación:

Outputs: ![Terraform Init](img/ev3/47_Terraform_Outputs_Post_Taint.png)

Lista de estado: ![Terraform Init](img/ev3/48_Terraform_State_List_Post_Taint.png)

(La desmarcación con terraform untaint forma parte de la lógica de evaluación, aunque la evidencia explícita puede estar integrada en los outputs y state list posteriores.)

## Escenario 3 — Eliminación de recursos del estado (terraform state rm) sin borrar en AWS
En este escenario se deja de administrar el Security Group desde Terraform, sin eliminar el recurso real de la infraestructura.

1. Identificación del módulo y limpieza de código
   Eliminación del módulo de Security Group y ajustes necesarios en main.tf y outputs.tf del módulo VPC para dejar de exponer el SG como output administrado:

Evidencias:

Eliminación del módulo SG: ![Terraform Init](img/ev3/49_Eliminar_Modulo_Security_Group.png)

Modificación de main.tf para SG/VPC: ![Terraform Init](img/ev3/50_Modificacion_Security_Group_Main.png)

Modificación del módulo VPC en el repo de módulos (main.tf y outputs.tf): ![Terraform Init](img/ev3/51_Modificacion_Repo_Modulos_VPC_Main.png), ![Terraform Init](img/ev3/52_Modificacion_Repo_Modulos_VPC_Outputs.png)

2. Actualización de providers/versions e inicialización
   Actualización de versiones y providers (por ejemplo, para compatibilidad con módulos) y nueva inicialización:

Evidencia: ![Terraform Init](img/ev3/53_Terraform_Init_Upgrade.png)

3. Validación final de que no hay cambios
   Ejecución de terraform plan confirmando que la infraestructura coincide con la configuración (sin intentos de recrear el SG eliminado del código y del estado):

Evidencia: ![Terraform Init](img/ev3/54_Terraform_Plan_No_Chances.png)

Conclusiones
Se logró reconstruir completamente un archivo de estado perdido mediante terraform state import, garantizando que Terraform reconoce todos los recursos desplegados sin generar cambios inesperados.

Se aplicó terraform refresh para sincronizar el estado con cambios manuales hechos en la consola de AWS, comprendiendo las diferencias entre configuración deseada y estado real.

Se utilizó terraform taint para forzar la recreación controlada de la instancia EC2, verificando el impacto en plan, apply y outputs.

Se demostró cómo eliminar un recurso del estado (state rm) y del código sin borrar el recurso en AWS, manteniendo la infraestructura intacta pero fuera de la administración de Terraform.

Este README reemplaza al informe en PDF solicitado originalmente, documentando el paso a paso con referencias directas a las evidencias visuales almacenadas en img/ev3.