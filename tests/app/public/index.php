<?php

// Stands in for Laravel: nginx sends every path here, /up included.
header('Content-Type: text/plain');
echo $_SERVER['REMOTE_ADDR'];
