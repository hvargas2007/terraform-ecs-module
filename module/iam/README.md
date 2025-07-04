# Módulo IAM

## 📋 Descripción

Este módulo crea los roles y políticas IAM necesarios para ejecutar servicios ECS. Incluye tanto el rol de ejecución (para que ECS pueda lanzar tareas) como el rol de tarea (permisos que tiene la aplicación en ejecución).

## 🎯 Recursos Creados

- `aws_iam_role.ecs_execution_role`: Rol para la ejecución de tareas ECS
- `aws_iam_role.ecs_tasks_role`: Rol para las tareas en ejecución
- `aws_iam_policy.ecs_policy`: Política con permisos necesarios
- `aws_iam_role_policy_attachment`: Asociaciones de políticas a roles

## 📥 Variables de Entrada

| Variable | Descripción | Tipo | Requerido | Default |
|----------|-------------|------|-----------|---------|
| `name_prefix` | Prefijo para nombres de recursos IAM | `string` | ✅ | - |

## 📤 Outputs

| Output | Descripción | Tipo |
|--------|-------------|------|
| `execution_role_arn` | ARN del rol de ejecución | `string` |
| `task_role_arn` | ARN del rol de tarea | `string` |

## 💡 Ejemplo de Uso

```hcl
module "iam" {
  source = "./module/iam"
  
  name_prefix = "mi-proyecto-dev"
}
```

## 🔍 Notas Importantes

### Rol de Ejecución
El rol de ejecución es usado por el agente de ECS para:
- Descargar imágenes de ECR
- Crear y gestionar logs en CloudWatch
- Obtener secretos de Parameter Store/Secrets Manager

### Rol de Tarea
El rol de tarea es usado por la aplicación en contenedor para:
- Acceder a servicios de AWS desde dentro del contenedor
- Leer/escribir en S3
- Acceder a DynamoDB
- Ejecutar comandos ECS (exec)

## 🔐 Permisos Incluidos

### CloudWatch
- Crear grupos y streams de logs
- Escribir eventos de logs
- Describir grupos y streams

### ECR (Elastic Container Registry)
- Obtener token de autorización
- Descargar imágenes
- Verificar capas

### ECS
- Registrar/actualizar definiciones de tareas
- Gestionar servicios
- Ejecutar comandos (ECS Exec)

### Systems Manager (SSM)
- Obtener parámetros
- Crear canales de comunicación para ECS Exec
- Descifrar valores usando KMS

### S3
- Listar buckets
- Obtener objetos
- Operaciones básicas de lectura

### EFS (Elastic File System)
- Montar sistemas de archivos
- Operaciones de cliente

## ⚠️ Seguridad

- Los permisos están configurados de forma amplia para flexibilidad
- En producción, considera restringir los permisos a recursos específicos
- Usa condiciones en las políticas para mayor seguridad
- Revisa regularmente los permisos otorgados

## 🔗 Recursos Relacionados

- [ECS Task IAM Roles](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [ECS Exec](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html)