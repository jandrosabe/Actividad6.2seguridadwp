# Como ampliar la seguridad en un sitio web realizado a través de WordPress.

1. Usando wpscan:
Esta aplicación la podemos implementar a través de docker de su [página web oficial](https://wpscan.com/).
Una vez instalado lanzamos el comando en mi caso para mi sitio ```docker run --rm wpscanteam/wpscan --url http://infof1.free.nf/wp-admin --random-user-agent --force ``` para lanzar el escaneo y viendo los resultados podemos tomar algunas decisiones. 
En mi caso me detectó la vulnerabilidad de tener público el archivo WP-Cron, por lo que lo pondré para que no sea accesible por cualquiera a traves de la [url básica](http://infof1.free.nf/wp-cron.php). Para esto vamos al archivo ```.htaccess``` y en el escrbimos: 
```bash
<Files "wp-cron.php">
    order deny,allow
    Deny from all
    Allow from 'ip-publica-permitir'
</Files>
```

2. Cambio prefijo de la tablas en la base de datos WordPress.
Por defecto estas tablas contienen el prefijo "wp_" pero esto puede llegar a ser peligroso sobre todo si se tiene mas de un sitio web con su correspondiente base de datos.
Con esto se previenen posibles ataques relacionandos con las bases de datos.
Para realizar el cambio primero vamos al archivo ```wp-config.php``` y modificamos la linea ```$table_prefix = 'wp_;``` por el prefijo que se quiera ```$table_prefix = 'fi_;```. Este cambio no vale si o se modifica en la base de datos el prefijo de las tablas. 
Se puede hacer a través de un plugin (antes de cambiar el archivo wp-config) o a través de php-myadmin y lenguaje sql tabla a tabla.
```bash
RENAME TABLE wp_actionscheduler_actions TO fi_actionscheduler_actions;
RENAME TABLE wp_actionscheduler_claims TO fi_actionscheduler_claims;
RENAME TABLE wp_actionscheduler_groups TO fi_actionscheduler_groups;
RENAME TABLE wp_actionscheduler_logs TO fi_actionscheduler_logs;
RENAME TABLE wp_wpforms_logs TO fi_wpforms_logs;
RENAME TABLE wp_wpforms_payments TO fi_wpforms_payments;
RENAME TABLE wp_wpforms_payment_meta TO fi_wpforms_payment_meta;
RENAME TABLE wp_wpforms_tasks_meta TO fi_wpforms_tasks_meta;

```

En todas las tablas.


3. Modificar y no usar nombres com admin o administrador.
Como no se puede modificar directamente en el perfil de wordpress, vamos a modificar nuevamente la base de datos.
Para esto usamos las querys siguientes.

```bash
UPDATE fi_users SET user_login = 'Alejandro' WHERE user_login = 'admin';
```
Con esta cambiamos el nombre con el que iniciamos sesión y con la siguiente el nombre público que aparece.
```bash
UPDATE fi_users SET display_name = 'paco', user_nicename = 'paco' WHERE user_login = 'Alejandro';
```

4. Bloquear el acceso a archivos cruciales desde el enalce. 

Como en el apartado 1 desde el fichero ```.htaccess``` restringiremos el acceso desde el enlace a diversos ficheros importantes.
Una vez elegidos los mas importantes quedarian así restringidos.
```bash
<Files "wp-config.php">
    order deny,allow
    Deny from all
    Allow from 'ip-publica-permitir'
</Files>

<Files "readme.html">
    order deny,allow
    Deny from all
    Allow from 'ip-publica-permitir'
</Files>

<Files "xmlrpc.php">
    order deny,allow
    Deny from all
    Allow from 'ip-publica-permitir'
</Files>

<Files ".htaccess">
    order deny,allow
    Deny from all
    Allow from 'ip-publica-permitir'
</Files>
```

Los archivos mas importantes bloqueados.


5. Deshabilitar la edición de archivos desde el panel de WordPress.
Esta función es útil por si el atacante consigue entrar al usuario administrador, no podría modificar archivos críticos ni inyectar malware fácilmente.
Para bloquear esto modificaremos el archivo ```wp-config.php```:

```
/* Add any custom values between this line and the "stop editing" line. */

define('DISALLOW_FILE_EDIT', true);


/* That's all, stop editing! Happy publishing. */
```


6. Deshabilitar sugerencias de inicio de sesión.

Fallar el inicio de sesión puede dar pistas como por ejemplo "nombre de ususario incorrecto" "contraseña incorrecta". 
Para evitar estas pistas podemos instalar y modificar el plugin loginizer.
Para modificar y cambiar esto vamos a fuerza bruta y bajamos hasta mensajes de error, aquí cambiamos el mensaje de Intento de acceso fallido por el que queramos: ```Intento de acceso fallido ``` a ```Acceso incorrecto```.


7. Limitar intentos máximos para iniciar sesión
Menos oportunidades de iniciar sesión menos posibilidades de ser atacado por fuerza bruta y logren entrar. Esto se puede lograr también con el plugin anteriormente mencionado en el apartado de ajustes de fuerza bruta.
```bash
Intentos máximos  2	Número máximo de intentos fallidos antes del bloqueo
Duración del bloqueo 30	minutos
Máximo de bloqueos 	5
Ampliar el bloqueo 24	 horas. Extiende la duración del bloqueo después de alcanzar el máximo de bloqueos.
Restablecer los intentos 24	horas 
```

8. Ocultar información sobre la versión del servidor y PHP.
Para no darle pistas de posibles fallos que tuvieran versiones pasadas podemos añadir esta lineas al archivo .htaccess.

```
ServerSignature Off
Header unset X-Powered-By
```


9. Modificar acceso a la administración de WordPress.
    Por defecto esta dirección es wp-admin pero podemos modificar su acceso con .htaccess. Añadimos estas lineas.
 ```
<Files "wp-admin">
    order deny,allow
    Deny from all
    Allow from '83.35.4.94'
</Files>
 ```