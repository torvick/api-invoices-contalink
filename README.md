# api-invoices-contalink

API en **Ruby on Rails** para consulta de facturas con:

- Cache de respuestas vía **Redis** (TTL 10 min).
- **Sidekiq** para jobs en background y **sidekiq-cron** para envío diario por email del **Top 10 de días con más ventas**.
- Endpoint JSON para listar facturas por rango de fechas (con filtros, orden y paginación).

---

## Requisitos

- Ruby `3.2.x`
- Rails `7.1.x`
- Redis `>= 6`
- PostgreSQL (o la BD que tengas configurada)
- Bundler `>= 2.5`

---

## Variables -> (Rails Credentials)

En este proyecto **no usamos variables de entorno directas**; todo se gestiona con **Rails Credentials**.  

### Cómo configurarlas

1) Abrir credenciales  
Global:
```bash
bin/rails credentials:edit
```
---


## Instalación

```bash
bundle install
```

---

## Arranque en Desarrollo

### 1) Redis
**macOS (Homebrew)**
```bash
brew services start redis
# o temporal
redis-server
```

**Linux (Ubuntu)**
```
sudo apt update
sudo apt install -y redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server
sudo systemctl status redis-server
```

### 2) Habilitar caché en development
```bash
bin/rails dev:cache
# Debe mostrar: "Development mode is now being cached."
```

### 3) Levantar Rails y Sidekiq (dos terminales)

**Rails**
```bash
bin/rails s
```

**Sidekiq**
```bash
bundle exec sidekiq -C config/sidekiq.yml
# Debe verse: [cron] loaded N job(s)
```

### 4) Panel de Sidekiq
Abre: `http://localhost:3000/sidekiq`

- Pestaña **Cron**: debe verse el job diario (ej. `top_selling_days_daily`).

---

## Endpoints

### GET `/api/v1/invoices`

**Parámetros de query**

| Parámetro        | Tipo           | Req | Descripción                                        |
|------------------|----------------|-----|----------------------------------------------------|
| `start_date`     | `YYYY-MM-DD`   | Sí  | Fecha inicial (inclusive)                          |
| `end_date`       | `YYYY-MM-DD`   | Sí  | Fecha final (inclusive)                            |
| `invoice_number` | `string`       | No  | Filtro por número                                  |
| `status`         | `string`       | No  | Filtro por estatus                                 |
| `sort_by`        | `id \| invoice_date \| invoice_number \| total \| status` | No | Default `invoice_date` |
| `sort_dir`       | `asc \| desc`  | No  | Default `asc`                                      |
| `page`           | `integer`      | No  | Default `1`                                        |
| `per_page`       | `integer`      | No  | Default `50` (máx recomendado `200`)               |

**Respuesta (200)**
```json
{
  "data": {
    "invoices": [ /* ... */ ]
  },
  "meta": {
    "count": 123,
    "page": 1,
    "per_page": 50,
    "total_pages": 3,
    "sort_by": "invoice_date",
    "sort_dir": "asc"
  }
}
```

**Ejemplo cURL**
```bash
curl "http://localhost:3000/api/v1/invoices?start_date=2022-01-01&end_date=2022-01-10&status=Cancelado&page=1&per_page=200&sort_by=invoice_date&sort_dir=desc"
```

---

## Tests

- RSpec inicializado (`.rspec`, carpeta `spec/`).
```bash
bundle exec rspec
```
