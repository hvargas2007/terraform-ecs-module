# Módulo ALB Listener

## 📋 Descripción

Este módulo crea los listeners HTTP y HTTPS para el Application Load Balancer. Los listeners determinan cómo el ALB maneja las conexiones entrantes y las redirige a los target groups apropiados.

## 🎯 Recursos Creados

- `aws_lb_listener.http`: Listener HTTP (puerto 80)
- `aws_lb_listener.https`: Listener HTTPS (puerto 443) - opcional

## 📥 Variables de Entrada

| Variable | Descripción | Tipo | Requerido | Default |
|----------|-------------|------|-----------|---------|
| `alb_arn` | ARN del Application Load Balancer | `string` | ✅ | - |
| `https_enabled` | Si se debe crear un listener HTTPS | `bool` | ❌ | `false` |
| `acm_certificate_arn` | ARN del certificado ACM para HTTPS | `string` | ❌ | `""` |
| `ssl_policy` | Política SSL para el listener HTTPS | `string` | ❌ | `"ELBSecurityPolicy-2016-08"` |
| `project_tags` | Tags a aplicar a los recursos | `map(string)` | ✅ | - |

## 📤 Outputs

| Output | Descripción | Tipo |
|--------|-------------|------|
| `http_listener_arn` | ARN del listener HTTP | `string` |
| `https_listener_arn` | ARN del listener HTTPS (si está habilitado) | `string` |

## 💡 Ejemplo de Uso

### Solo HTTP
```hcl
module "alb_listeners" {
  source = "./module/alb_listener"
  
  alb_arn      = module.alb.alb_arn
  project_tags = local.common_tags
}
```

### HTTP y HTTPS
```hcl
module "alb_listeners" {
  source = "./module/alb_listener"
  
  alb_arn             = module.alb.alb_arn
  https_enabled       = true
  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789:certificate/abc-123"
  ssl_policy          = "ELBSecurityPolicy-TLS-1-2-2017-01"
  project_tags        = local.common_tags
}
```

## 🔍 Notas Importantes

- El listener HTTP siempre se crea con una acción por defecto que devuelve 503
- Si HTTPS está habilitado, también redirige HTTP a HTTPS automáticamente
- Para usar HTTPS, debes tener un certificado SSL/TLS válido en AWS Certificate Manager
- Las reglas específicas de enrutamiento se configuran en el módulo `alb_targetgroup`

## 🔒 Políticas SSL Recomendadas

- `ELBSecurityPolicy-TLS-1-2-2017-01`: Buena compatibilidad con TLS 1.2+
- `ELBSecurityPolicy-TLS13-1-2-2021-06`: Más segura, requiere TLS 1.2+
- `ELBSecurityPolicy-FS-1-2-Res-2020-10`: Forward Secrecy con TLS 1.2+

## 🔗 Recursos Relacionados

- [AWS ALB Listeners](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html)
- [SSL Security Policies](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies)