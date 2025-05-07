#!/bin/bash

# Ruta al directorio de WordPress en mi caso raiz
WP_ROOT="."

# Tu IP pública permitida en mi caso 
MI_IP="83.35.4.94"

# Crear o sobrescribir .htaccess
cat <<EOF > "$WP_ROOT/.htaccess"
# Seguridad básica

ServerSignature Off
Header unset X-Powered-By

<Files "wp-config.php">
    Order deny,allow
    Deny from all
    Allow from $MI_IP
</Files>

<Files "readme.html">
    Order deny,allow
    Deny from all
    Allow from $MI_IP
</Files>

<Files "xmlrpc.php">
    Order deny,allow
    Deny from all
    Allow from $MI_IP
</Files>

<Files ".htaccess">
    Order deny,allow
    Deny from all
    Allow from $MI_IP
</Files>

<Files "wp-cron.php">
    Order deny,allow
    Deny from all
    Allow from $MI_IP
</Files>

<Files "wp-admin">
    Order deny,allow
    Deny from all
    Allow from $MI_IP
</Files>
EOF

echo "[✔] .htaccess creado correctamente con reglas de seguridad."

# Modificar wp-config.php
if grep -q "define('DISALLOW_FILE_EDIT'" "$WP_ROOT/wp-config.php"; then
    echo "[!] Ya existe DISALLOW_FILE_EDIT en wp-config.php"
else
    sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i \
\n// Deshabilitar edición de archivos desde el panel\n\
define('DISALLOW_FILE_EDIT', true);\n" "$WP_ROOT/wp-config.php"
    echo "[✔] wp-config.php modificado para deshabilitar edición de archivos."
fi

# Cambiar prefijo de tablas (si aplica)
sed -i "s/^\$table_prefix\s*=\s*'wp_';/\$table_prefix = 'fi_';/" "$WP_ROOT/wp-config.php" && \
echo "[✔] Prefijo de tablas cambiado a 'fi_' en wp-config.php."

echo "[✅] Configuración de seguridad aplicada."
