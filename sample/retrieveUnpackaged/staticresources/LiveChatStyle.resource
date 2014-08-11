p {
	font-weight: bolder
}
label {
	width: 80px;
	font-weight: bold;
	font-size: 11.25pt;
	padding-bottom: 10px;
}

#chatHeader {
	background-color: #0097D2;
	padding-left: 10px; 
	height: 83px;
	-moz-box-shadow: 0 4px 5px rgba(0, 0, 0, 0.15);
	-webkit-box-shadow: 0 4px 5px rgba(0, 0, 0, 0.15);  
	box-shadow: 0 4px 5px rgba(0, 0, 0, 0.15);
}

#preChatContainer {
	display: block;
	margin: auto;
	padding: 15px;
	width: 370px;
	border: none;
	margin-top: 50px;
	background-color: #fff;
	-webkit-border-bottom-right-radius: 20px;
	-moz-border-radius-bottomright: 20px;
	border-bottom-right-radius: 20px;
	-moz-box-shadow: 0px 1px 7px rgba(0, 0, 0, 0.15);
	-webkit-box-shadow: 0px 1px 7px rgba(0, 0, 0, 0.15);
	box-shadow: 0px 1px 7px rgba(0, 0, 0, 0.15); 
	background-color: #fff;
	box-shadow: 0px 1px 10px rgba(0, 0, 0, 0.15)\9; 
	background: url(resource/SEWRoundedCornerF3F2F0) bottom right no-repeat #fff\9;
}
h3 {
	font-size: 15pt;
}
label {
	float: left;
	width: 120px;
	layout: block;
	padding-bottom: 20px;
}
input[type="text"] {
	float: left;
}

.inputRow {
	clear: both;
	padding-bottom: 10px;
}

body {
	font-family: Calibri, "Trebuchet MS", sans-serif; 
	font-size: 11.25pt; 
}

#chatHeader {
	background-color: #0097D2;
	padding-left: 10px; 
	height: 83px;
	-moz-box-shadow: 0 4px 5px rgba(0, 0, 0, 0.15);
	-webkit-box-shadow: 0 4px 5px rgba(0, 0, 0, 0.15);  
	box-shadow: 0 4px 5px rgba(0, 0, 0, 0.15);
}

#waitingMessage {
	font-weight: bold;
	margin: auto;
	margin-top: 50px;
	text-align: center;
}

#liveAgentChatLog {
	background-color: #fff;
	border-color: #959593 !important;
	border-radius:3px;
	-webkit-border-radius:3px;
	-moz-border-radius:3px;
	-moz-box-shadow: 0px 1px 7px rgba(0, 0, 0, 0.15);
	-webkit-box-shadow: 0px 1px 7px rgba(0, 0, 0, 0.15);
	box-shadow: 0px 1px 7px rgba(0, 0, 0, 0.15);
	padding: 5px;
	margin: 10px;
	overflow-y:auto;
	overflow-x:hidden;
}

#chatInput {
	margin: 10px;  
}

#liveAgentChatInput {
	width: 335px;
	height:38px;
	//overflow-y:scroll;             
}

.liveAgentStateWaiting #waitingMessage {
	display: block;
}

.liveAgentState #waitingMessage,
.liveAgentStateEnded #waitingMessage {
	display: none;
}

.liveAgentState #closebtn,
.liveAgentStateWaiting #closebtn {
	display: none;
}

.liveAgentStateEnded #closebtn,
.liveAgentStateStatusMessage #closebtn {
	display: block;	
}

.liveAgentStateEnded #liveAgentChatInput {
	display: none;
}

.liveAgentSendButton, .liveAgentEndButton, .liveAgentSaveButton {
	overflow: visible;
	background-repeat: repeat-x;
	border: 0 !important;
	border-spacing: 0 !important;
	background-image: none;
	color: #fff;
	display: inline;
	font-family: Calibri, "Trebuchet MS", sans-serif; !important;
	font-weight: bold;
	font-size: 11.25pt;
	margin: 2px 3px 2px 0px;
	border-radius:3px;
	-webkit-border-radius:3px;
	-moz-border-radius:3px;
	padding: 3px 8px;
	-moz-box-shadow: 2px 2px 3px rgba(0, 0, 0, 0.25);
	-webkit-box-shadow: 2px 2px 3px rgba(0, 0, 0, 0.25);
	box-shadow: 2px 2px 3px rgba(0, 0, 0, 0.25);            
}

.liveAgentSendButton {
	background-color: #5da22a;
	margin-left:8px;
	margin-top:8px;
	position: relative;
	top: -5px;
}
.liveAgentSendButton:hover {
	background-color: #3f8418;
	cursor: pointer;
}

.liveAgentEndButton {
	/*background-color: #0097d2;
	margin-left: 85px; -- button style*/
	background-color: transparent;
	color: #5da22a !important;
	-moz-box-shadow: none;
	-webkit-box-shadow: none;
	box-shadow: none;
}

.liveAgentEndButton:hover {
	/*background-color: #0072bc;  
	cursor: pointer; -- button style */
	background-color: transparent;
	color: #3f8418 !important;       
}

.liveAgentSaveButton, .liveAgentSaveButton:focus {
	background-color: transparent;
	color: #0097d2 !important;
	-moz-box-shadow: none;
	-webkit-box-shadow: none;
	box-shadow: none;
	margin-left: 0;
	padding: 0;
}

.liveAgentSaveButton:hover {    
	background-color: transparent;
	color: #0072d2 !important; 
	cursor: pointer;
}

.client strong {
	color: #3f8418;
}

.operator strong {
	color: #0072d2;
}

.saveTranscript {float:left;margin-left:14px;margin-top:11px;width:120px;display:inline;}

.endChat {float:left;margin-left:220px;margin-top:8px;display:inline; cursor:pointer;}
