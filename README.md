# Gestión de Repositorios con Git Subtree

Este repositorio (`rpo_padre_subtree`) utiliza **`git subtree`** para integrar y gestionar el código de otros proyectos (hijos) en subdirectorios específicos. Esta técnica permite mantener el historial de *commits* de cada proyecto hijo separado y facilita la contribución bidireccional, manteniendo la unidad del repositorio principal.

## 1. Estructura de Repositorios

| Nombre del Proyecto | Rol | URL Remota | Prefijo (Carpeta) | Remote Name (Alias) |
| :--- | :--- | :--- | :--- | :--- |
| `rpo_padre_subtree` | **Padre** (Este Repo) | `https://github.com/scruc1990/rpo_padre_subtree.git` | N/A | `origin` |
| `rpo_hijo_1` | Hijo Estándar | `https://github.com/scruc1990/rpo_hijo_1.git` | `hijo_1/` | `hijo1` |
| `rpo_hijo_2_fork` | Hijo (Fork) | `https://github.com/Nest-ms-fh/rpo_hijo_2_fork.git` | `hijo_2/` | `hijo2` |

## 2. Configuración Inicial de Git Subtree

Si estás configurando los *subtrees* por primera vez, sigue estos comandos desde la **raíz de `rpo_padre_subtree`** después de clonarlo:

### 2.1. Integración de `rpo_hijo_1` (`hijo1`)

1.  **Agregar el Remote:** Define el origen remoto para el hijo.
    ```bash
    git remote add hijo1 [https://github.com/scruc1990/rpo_hijo_1.git](https://github.com/scruc1990/rpo_hijo_1.git)
    ```
2.  **Añadir el Subtree:** Extrae el historial del hijo y lo inserta en la carpeta especificada. Se usa `--squash` para condensar el historial de entrada.
    ```bash
    git subtree add --prefix=hijo_1 hijo1 main --squash
    ```

### 2.2. Integración de `rpo_hijo_2_fork` (`hijo2`)

1.  **Agregar el Remote:**
    ```bash
    git remote add hijo2 [https://github.com/Nest-ms-fh/rpo_hijo_2_fork.git](https://github.com/Nest-ms-fh/rpo_hijo_2_fork.git)
    ```
2.  **Añadir el Subtree:**
    ```bash
    git subtree add --prefix=hijo_2 hijo2 main --squash
    ```


## 3. Flujo de Trabajo y Sincronización

Todos los comandos de `git subtree` **deben ejecutarse desde la raíz del repositorio padre** (`rpo_padre_subtree`).

### 3.1. Traer Cambios del Hijo al Padre (`git subtree pull`)

Se usa para actualizar el código de la carpeta local (`hijo_X/`) con los últimos *commits* del repositorio remoto del hijo.

| Proyecto | Comando de Actualización |
| :--- | :--- |
| **`rpo_hijo_1`** | `git subtree pull --prefix=hijo_1 hijo1 main` |
| **`rpo_hijo_2_fork`** | `git subtree pull --prefix=hijo_2 hijo2 main` |

### 3.2. Enviar Cambios del Padre al Hijo (`git subtree push`)

Se utiliza cuando has hecho *commits* que modifican archivos **dentro de las carpetas hijas** en el repositorio padre, y quieres que esos cambios se reflejen en el repositorio remoto del hijo.

** Advertencia:** Nunca uses solo `git push` desde las subcarpetas, ya que no son repositorios independientes.

| Proyecto | Comando de Envío |
| :--- | :--- |
| **`rpo_hijo_1`** | `git subtree push --prefix=hijo_1 hijo1 main` |
| **`rpo_hijo_2_fork`** | `git subtree push --prefix=hijo_2 hijo2 main` |

## 4. Comandos Adicionales y Atajos

### A. Verificar Remotes

Asegúrate de que los remotos estén correctamente configurados (debes ver `origin`, `hijo1`, y `hijo2`):

```bash
git remote -v