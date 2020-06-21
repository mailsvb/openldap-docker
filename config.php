<?php
$config->custom->appearance['hide_template_warning'] = true;
$servers = new Datastore();
$servers->newServer('ldap_pla');
$servers->setValue('server','name','OpenLDAP');
$servers->setValue('server','host','127.0.0.1');
$servers->setValue('server','port',389);
$servers->setValue('login','bind_id','cn=%ROOT_USER%,%SUFFIX%');
?>