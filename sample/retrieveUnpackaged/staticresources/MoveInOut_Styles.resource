/* Styles for Move In and Out */

/* steps */
.activeStep, .step, .stepIncomplete, .stepIncomplete2 {
	font-weight: bold;
	font-size: 15pt;
	color: #575756;
}

.activeStep, .step, .stepIncomplete2 {
	margin-right: 90px;
}

.stepIncomplete, .stepIncomplete2 { color: #959593  }

.activeStep {
	color: #fff;
}

.stepFirst {
	margin-left: 16px
}

.stepInnerGrid {
	height:45px; vertical-align: middle;
}

/* label width */
.bPageBlock .detailList .labelCol {
	width: 35% !important;
	text-align: left;
}

input[type="checkbox"] {
    border: medium none;
    margin-bottom: 7px;
    margin-top: 7px;
}

input[type="text"], input[type="textarea"]{
	width: 59%; !important;
}

.note {
	font-size: 12pt;
	color: #575756;
	margin-top: 15px;
	margin-bottom: 15px;
}

/* check box alignment */
.checkboxText {
   	top: -20px;
	position: relative;
	left: 30px;
	width: 290px;
}

/* fixes for chrome */
.dateOnlyInput input {
	width: auto;
}

/* background images for the steps */
.moveinoutstep1Image, .moveinoutstep2Image, .moveoutstep2Image, .completeImage, .moveinoutstep1of3Image, .moveinoutstep2of3Image, .moveinoutstep3of3Image, moveinout3stepcompleteImage { 
	background: no-repeat #D8EFF7;
	width: 730px; height: 47px; position: relative; top: -10px; left: -15px;
	
}
.moveinoutstep1Image {
	background-image: url(PortalMoveInOut1Step_Image);
	background-position: 0 0px; 	
}
.moveinoutstep2Image {
	background-image: url(TwoStepRegistration_Image);
	background-position: 0 -47px; 	
}
.completeImage {
	background-image: url(TwoStepRegistration_Image);
	background-position: 0 -94px; 	
}

.moveinoutstep1of3Image {
	background-image: url(PortalMoveInOut3Steps_Image);
	background-position: 0 0px; 	
}
.moveinoutstep2of3Image {
	background-image: url(PortalMoveInOut3Steps_Image);
	background-position: 0 -47px; 	
}
.moveinoutstep3of3Image {
	background-image: url(PortalMoveInOut3Steps_Image);
	background-position: 0 -94px; 	
}
.moveinout3stepcompleteImage {
	background-image: url(PortalMoveInOut3Steps_Image);
	background-position: 0 -141px; 	
}

.moveinout1stepcompleteImage {
	background-image: url(PortalMoveInOut1Step_Image);
	background-position: 0 -47px; 	
}

/*radio buttons*/
.moveoutOptions {
	margin: 0px auto;
	width: 100%;
	margin-top: 10px;
	margin-bottom: 10px;
}
.moveoutOptions td{
	width: 35%;
}
.moveoutOptions input, .moveoutOptions label{
	float: none;
	display: inline;
	width: 15px;
}
