/* Styles for registration */

.bodyDiv {
	padding-left:10px;
	padding-right:10px;
	margin-top: 20px;
	margin-bottom: 20px !important;
}

/* steps */
.activeStep, .step, .stepIncomplete {
	font-weight: bold;
	font-size: 15pt;
	color: #575756;
}

.activeStep, .step {
	margin-right: 90px;
}

.stepIncomplete { color: #959593  }

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
	width: 25%;
	text-align: left;
}

/* required field for inputtext */
.required {
    float: right;
	padding-top: 4px;
	left: 19px;
    position: relative;
}

.bPageBlock .pbButtonb {
	padding-left: 80px;
}

/* fixes for chrome */
.dateOnlyInput input {
	width: auto;
}

/* use a * for required field 
.bPageBlock .requiredInput .requiredBlock {
	position: absolute;
	left: -12px;
	width: 16px;
	top: 7px;
	bottom: 1px;
	background: url(RequiredFieldIcon) no-repeat transparent;
} */

.bPageBlock .pbTitle {
	line-height: 1;	
}

.bPageBlock .pbHeader {
	padding-right: 0px !important;
	padding-top: 0px !important;
}

/* background images for the steps */
.step1Image, .step2Image, .step3Image, .completeImage { 
	background: no-repeat #D8EFF7;
	width: 700px; height: 47px; position: relative; top: -10px; left: -15px;
	
}
.step1Image {
	background-image: url(PortalRegistrationSteps_Image);
	background-position: 0 0; 	
}
.step2Image {
	background-image: url(PortalRegistrationSteps_Image);
	background-position: 0 -47px; 	
}
.step3Image {
	background-image: url(PortalRegistrationSteps_Image);
	background-position: 0 -94px; 	
}
.completeImage {
	background-image: url(PortalRegistrationSteps_Image);
	background-position: 0 -141px; 	
}


