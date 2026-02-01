# ERD ChatGPT System 

**Sistema ChatGPT = Usuarios + Proyectos + Conversaciones + Mensajes + Memorias**

```
Usuario
  ├─ Proyectos (carpetas de conversaciones)
  │   └─ Conversaciones (chats)
  │       ├─ Mensajes (historial)
  │       └─ Participantes (one to many, múltiples usuarios)
  └─ Memorias (qué recuerda del usuario)
```

---

## 📊 Tabla de Entidades

| Entidad | Tipo | Relación | Notas |
|---------|------|----------|-------|
| **Users** | Existente | Central | Firebase UID como PK |
| **Projects** | Nueva | 1:N con Users | Agrupa conversaciones |
| **Conversations** | Nueva | N:M con Users | Via `user_conversation` |
| **Messages** | Nueva | 1:N con Conversations | Historial de chat |
| **Models** | Nueva | Global | Catálogo de LLMs |
| **Memories** | Nueva | 1:N con Users | Contexto persistente |
| **UserConversation** | Nueva | Asociación | Tabla explícita N:M |

---

## 🔑 Campos Clave por Tabla

### USERS (Existente)
```
user_id (PK) → Firebase UID
email, name
subscription_active
stripe_subscription_id
```

### PROJECTS
```
id (PK)
user_id (FK) → Owner
name, description
is_active → true/false
created_at, updated_at
```

### CONVERSATIONS
```
id (PK)
project_id (FK) → Belongs to 1 project ONLY
model_id (FK) → Uses 1 model
title
status → active/archived/deleted
created_at, updated_at
```

### MESSAGES
```
id (PK)
conversation_id (FK)
user_id (FK) → Who sent it
content
role → user/assistant/system
tokens_used → Para billing
created_at
```

### USER_CONVERSATION (Relación N:M)
```
user_id (PK/FK)
conversation_id (PK/FK)
joined_at
role → owner/participant/viewer
last_accessed_at
```

### MEMORIES
```
id (PK)
user_id (FK) → Owner
conversation_id (FK, NULLABLE) → Context
content
memory_type → preference/fact/context/behavior
importance_score → 1-10
created_at
expires_at → NULLABLE (TTL)
```

### MODELS
```
id (PK)
model_name (UNIQUE) → gpt-4, claude-opus
model_version
provider → OpenAI, Anthropic
context_window, max_tokens
cost_per_1k_tokens
created_at, updated_at
```

---

## 🔗 Relaciones Visual

```
USERS (1) ───────┬────────→ (N) PROJECTS
                 │
                 ├────────→ (1:1) EC2INSTANCES
                 ├────────→ (N) AGENTS
                 ├────────→ (N) SECRETS_BINDING
                 ├────────→ (N) DEPLOYMENTS
                 └────────→ (N) MEMORIES

PROJECTS (1) ───→ (N) CONVERSATIONS

CONVERSATIONS (1)────────┬──→ (N) MESSAGES
                         ├──→ (N) MEMORIES (origin)
                         └──→ (1) MODELS

USERS ←─────── (N:M) ─────→ CONVERSATIONS
              via USER_CONVERSATION

MESSAGES ──→ (N) USERS
           (quién envió)
```

---

## 💡 Supuestos Clave

| Supuesto | Implementación | Por qué |
|----------|---|---|
| Una conversación = 1 proyecto | FK project_id NOT NULL | Organización clara |
| Múltiples usuarios en conversación | Tabla user_conversation | Flexibilidad |
| Memorias reutilizables | Entity independiente | Contexto persistente |
| Modelos son globales | Sin FK a usuario | Evita duplicación |
| Mensajes se guardan | Tabla messages | Auditoría y análisis |
| Participación puede tener roles | Campo role en user_conversation | Control granular |
| Memorias pueden expirar | Campo expires_at | TTL automático |

**P: ¿Las memorias se comparten entre proyectos?**
A: Sí, las memorias son globales por usuario (no boundadas a proyectos).

**P: ¿Cómo calculo el costo?**
A: `SUM(tokens_used) / 1000 * cost_per_1k_tokens` (en tabla models).

**: ¿Se pueden tener conversaciones sin mensajes?**
A: Depende, una conversación vacía es válida pero si nunca inicia con un mensaje se podría quedar innecesariamente la conversación ahí vacía, es mejor que en el front se vea la conversacion pero en realidad aun no tenga session_id, sino hasta que se manda el primer mensaje.

**P: ¿Necesito modelo_id al crear conversación?**
A: Sí, la conversación debe usar un modelo.