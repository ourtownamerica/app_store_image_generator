<?php
$here = realpath(dirname(__FILE__));

$messages = json_decode(file_get_contents("$here/messages.json"), true);
$screenshot_sizes = json_decode(file_get_contents("$here/screenshot_sizes.json"), true);

foreach($screenshot_sizes as $platform=>$sizes){
	foreach($messages as $file=>$message){
		$src_img = "$here/$platform/$file.png";
		if(!file_exists($src_img)){
			echo "missing file: $src_img\n";
			continue;
		}
		foreach($sizes as $size_inches=>$size){
			if(!regen($platform, $file, $size_inches)) continue;
	
			list($width, $height) = explode("x", $size);
			$output_file = "$here/out/$platform"."_$size_inches"."_$file.png";
			$cmd = escapeshellarg("$here/generate.sh")." ".escapeshellarg($width)." ".escapeshellarg($height)." ".escapeshellarg($src_img)." ".escapeshellarg($message)." ".escapeshellarg($output_file);
			$result = runcmd($cmd);

			echo basename($output_file).":\n";
			if(!empty($result->stderr)){
				echo "\tError: ".$result->stderr."\n";
			}
			if(!empty($result->stdout)){
				echo "\t".$result->stdout."\n";
			}
			echo "\n";
		}
		
	}
}

// Does the file need to be regenerated
function regen($platform, $file, $size_inches){
	if($platform === 'android_phone' || $platform === 'android_tablet') return true;
	if($platform === 'ipad'){
		if($size_inches === '9.7'){
			if($file === 'scan') return true;
			if($file === 'sponsor_activity') return true;
			if($file === 'sponsor_info') return true;
			if($file === 'sponsor_map') return true;
		}
	}
	if($platform === 'iphone'){
		if($size_inches === '3.5'){
			if(in_array($file, ['home', 'login', 'preferences', 'scan', 'sponsor_map'])) return true;
		}
		if($size_inches === '4'){
			if(in_array($file, ['login', 'sponsor_activity', 'sponsor_info', 'sponsor_map'])) return true;
		}
	}
	return false;
}

/**
 * Run a command with optional stdin
 * @param string $cmd - the command to run
 * @param string|string[] $stdin - the stdin to feed to the command
 * @param string $cwd - the working directory in which to run the command
 * @return object containing exit_status, stdout, stderr and elapsed
 */
function runcmd($cmd, $stdin=null, $cwd=null){
	if(empty($cwd)) $cwd = getcwd();
	if(empty($stdin)) $stdin = array();
	if(!is_array($stdin)) $stdin = array($stdin);
	
	$started = microtime(true);
	
	$descriptorspec = array(
		0 => array("pipe", "r"),  // stdin is a pipe that the child will read from
		1 => array("pipe", "w"),  // stdout is a pipe that the child will write to
		2 => array("pipe", "w")   // stderr is a pipe that the child will write to
	);
	$process = proc_open($cmd, $descriptorspec, $pipes, $cwd);
	
	$stderr = '';
	$stdout = '';
	$status = 0;
	
	if (is_resource($process)) {
		foreach($stdin as $input){
			fwrite($pipes[0], $input);
		}
		fclose($pipes[0]);

		$stdout = stream_get_contents($pipes[1]);
		fclose($pipes[1]);

		$stderr = stream_get_contents($pipes[2]);
		fclose($pipes[2]);

		$status = proc_close($process);
	}else{
		$stderr = 'Unable to run command.';
		$status = 1;
	}

	$elapsed = microtime(true) - $started;
	
	return (object) array(
		'exit_status' => $status,
		'stderr' => $stderr,
		'stdout' => $stdout,
		'elapsed' => $elapsed
	);
}