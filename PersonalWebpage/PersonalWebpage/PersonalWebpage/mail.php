<?php

if(isset($_POST['submit'])){
	$to = "pratikjo@usc.edu";	//this is the email of the recepient of the email
	$from = $_POST["email"];	//this is the sender's email address
	$name = $_POST['name'];
	$subject = "Contact from ".$_POST['homepage'];
	$message = $name." says:\n\n" .$_POST['message'];
	$headers = "From:".$from;
	if(mail($to, $subject, $message, $headers))
		echo "Mail sent. Thank You! Pratik will contact you as soon as possible :)";
	else
		echo "Some error in sending the mail";
	
	// echo "Mail sent. Thank You! Pratik will contact you as soon as possible :)";
	// header("Location: index.html");
}
?>