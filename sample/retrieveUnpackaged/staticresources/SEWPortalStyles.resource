/*** GENERAL ***/
/* New font and background */
body {
	font-family: Calibri, "Trebuchet MS", sans-serif;
	background-color: #f3f2f0;
}

.bodyDiv { font-size: 11.25pt }

select, input, textarea { 
	font-family: Calibri, "Trebuchet MS", sans-serif; 
	color: #252525;
	font-size: 11.25pt;	
}

.ui-widget, .sfdc_richtext {
    font-family: Calibri, "Trebuchet MS", sans-serif !important;
}

/* resize and colour input boxes */
input, textarea { padding: 3px; border: solid 1px #0097D2; }

select { 
	padding: 3px; border: solid 1px #0097D2;
	border-radius:3px;
	-webkit-border-radius:3px;
	-moz-border-radius:3px;
}

input[type="checkbox"], input[type="radio"] { border: none; }
/* ie hacks to put border around ie input file */
input[type="file"] { font-size: 10pt; border: none; *border: solid 1px #0097D2; border: solid 1px #0097D2\0/;    }


select:focus, input:focus, textarea:focus {
	-moz-box-shadow: 0px 0px 6px #0097D2;
	-webkit-box-shadow: 0px 0px 6px #0097D2;
	box-shadow: 0px 0px 6px #0097D2;
	outline: none; 
}

input[type="submit"]:focus {
	-moz-box-shadow: none;
	-webkit-box-shadow: none;
	box-shadow: none;	
}

/* labels */
.bPageBlock .labelCol, .bPageBlock .labelCol a {
	font-family: Calibri, "Trebuchet MS", sans-serif;
	text-align: left;
	font-size: 11.25pt;
	font-weight: normal;
}

.bPageBlock .labelCol {
	padding-left: 0px;	
}

label {
	color: #575756;	
}

.bPageBlock .requiredInput {
	float: left;
	padding-right: 3px;	
}

/* data col */
.bPageBlock .detailList .data2Col {
	color: #252525;
}

/* date picker */
.datePicker {
    //background-color: #0097D2;
}

/*** CONTAINERS ***/
/* DIV STYLES TO CENTER PAGE CONTENTS */
.shell900 {
   	overflow:visible;
    margin:auto;
    width:900px;
    font-family: Calibri, "Trebuchet MS", sans-serif;
    padding:0px;
    text-align:left;
    display:block;
}

.shell950 {
	overflow:visible;
    margin:auto;
    width:950px;
    font-family: Calibri, "Trebuchet MS", sans-serif;
    padding:0px;
    text-align:left;
    display:block;
}

/* Body DIV to center page contents*/
.bodyDiv {
	margin: auto;
	width: 1000px;
	display:block;
	border: none;
	background: transparent;
	padding-bottom: 5px;
}

/* can't remember what this did? */
.multiforce .navLinks A {
	color: #0097D2;
}

#bodyTable {
	margin-bottom: 10px;
}

/* SECTION DIVIDER */
.pbSectionDivider {
	border-bottom: 1px #575756 solid;
	width: 100%;
	height: 2px;
	overflow: hidden;
}

/* PAGE BLOCK TITLES */
.pageBlockTitle {
	font-size:22.5pt;
	color: #575756;
}

.bPageBlock .pbTitle {
	width: 100%;
}

.pbHeader .pbTitle h2 {
	font-size:22.5pt !important;
	color: #575756 !important;
	font-weight: normal;
	display: inline;
	width: 100%;
	height: 100%;
	font-family: Calibri, "Trebuchet MS", sans-serif;
}

.pbBody .bPageBlock .pbHeader {
	color: #575756;	
}

.pbHeader .pbTitle h2, .pbHeader .pbTitle h3 {
	margin-left: 0px;	
}

/*** section header styling ***/
body .bPageTitle .secondaryPalette {
	font-size:22.5pt !important;
	color: #575756 !important;
	font-weight: normal;
	display: inline;
	width: 100%;
	height: 100%;
	font-family: Calibri, "Trebuchet MS", sans-serif;
}

.bPageTitle {margin-top: 13px}

.bPageTitle .ptBody .content {
	padding-left: 15px;	
	padding-bottom: 10px;
	line-height: 1;
}	

.bPageTitle h1, .bPageTitle h2 {
    border: 0 none;
    font-size: 22.5pt !important;
    font-weight: normal;
}

.bPageTitle .ptBody .pageType {
	color: #959593 !important;	
}

.bPageTitle .ptBody .pageDescription {
	font-weight: normal;	
}

/*** PAGE BLOCK AND SECTION HEADERS ***/

/* Default page block - grey borders, rounded bottom right, white background */
.secondaryPalette.bPageBlock {
	padding: 0px;
	margin: 0px;
	margin-bottom: 10px;
	border: none;
	-webkit-border-bottom-right-radius: 20px;
	-moz-border-radius-bottomright: 20px;
	border-bottom-right-radius: 20px;
	-moz-box-shadow: 0px 1px 7px rgba(0, 0, 0, 0.15);
	-webkit-box-shadow: 0px 1px 7px rgba(0, 0, 0, 0.15);
	box-shadow: 0px 1px 7px rgba(0, 0, 0, 0.15); 
	background-color: #fff;
	box-shadow: 0px 1px 10px rgba(0, 0, 0, 0.15)\9; 
	background: url(SEWRoundedCornerF3F2F0) bottom right no-repeat #fff\9;
}


/* Transparent page block body - wrap page block around pbTransparent to get this */
.pbTransparent .secondaryPalette.bPageBlock {
	background-color: transparent;
	background-image: none;
	border: none;
	-webkit-border-bottom-right-radius: 0px;
	-moz-border-radius-bottomright: 0px;
	border-bottom-right-radius: 0px;
	-moz-box-shadow: none;
	-webkit-box-shadow: none;
	box-shadow: none;
}

/* styles that flush the left or right margin for the page block */
.pbNoLeftPad .bPageBlock .pbHeader { padding-left: 0px }
.pbNoLeftPad .bPageBlock .pbBody { padding-left: 0px }
.pbNoRightPad .bPageBlock .pbHeader { padding-right: 0px }
.pbNoRightPad .bPageBlock .pbBody { padding-right: 0px }
.pbNoTopPad .bPageBlock .pbHeader { padding-top: 0px }
.pbNoTopPad .bPageBlock .pbBody { padding-top: 0px }
.pbNoPad .bPageBlock .pbHeader { padding: 0px }
.pbNoPad .bPageBlock .pbBody { padding: 0px }

/* transparent tables have a white dotted border on header */
.pbWhiteDottedHeader .bPageBlock .pbHeader {
	border-bottom: 2px dotted #fff;
}

.pbMedGreyDottedHeader .bPageBlock .pbHeader {
	border-bottom: 1px dotted #E4E2DD;
}
	
/* padding around page block headers */
.bPageHeader .phHeader {
	padding: 5px 10px;
}
.bPageBlock .pbHeader {
	padding: 10px 15px;
	background-color: transparent;
}

/* Page Block Header font & colour */
.pageBlockHeader {
	height: 100%;
	color: #575756;
	font-family: Calibri, "Trebuchet MS", sans-serif;
	padding: 10px 15px;
	font-size: 22.5pt;
	font-weight: normal;
}

/* Page Block Body - padding around */
.bPageBlock .pbBody {
    padding: 10px 15px 20px;
}

.first.pbSubheader {
	margin-top: 10px !important;
}

.pbSubheader {
	color: #575756 !important;
	padding: 0px !important;
	margin-bottom: 10px !important;
	font-size: 12pt !important;
	margin-left: 0px !important;
}

.pbSubheader H3 {
    font-family: Calibri, "Trebuchet MS", sans-serif; !important;
    font-weight: bold;
    font-size: 11.25pt;
    color: #575756;
    display: block;
    padding-bottom: 5px;
}

.pbBottomButtons .pbTitle { 
	width: 30% !important;
}

/* add some margin to the bottom buttons */
.bPageBlock .pbBottomButtons {
	padding-bottom: 10px;	
}

/* HEADINGS AND SUBHEADINGS */
h1 {
    font-family: Calibri, "Trebuchet MS", sans-serif; !important;
    font-weight: normal;
    font-size:15pt;
    color: #575756;
	border-bottom: #E4E2DD 1px dotted;
	display: block;
}

h2 {
	font-family: Calibri, "Trebuchet MS", sans-serif; !important;
	font-weight:bold;
	font-size:15pt;
}

h3 {
    font-family: Calibri, "Trebuchet MS", sans-serif; !important;
    font-weight: bold;
    font-size: 11.25pt;
    color: #575756;
    display: block;
	border-bottom: dotted 1px #E4E2DD;
    padding-bottom: 5px;	
}

/* MESSAGE STYLES */
/* border around errors */
.message {
	background-color: #fff;	
	border-radius:5px;
	-webkit-border-radius:5px;
	-moz-border-radius:5px;
}

.bPageBlock .message { margin-bottom: 15px }

/* cross and padding for inline errors */
.bPageBlock .detailList .errorMsg {
    background: url(ListBulletCross_Orange) no-repeat scroll 0 1px transparent;
    padding-left: 20px;
}

/* error and warning styles */
.errorM6, .errorM4, .errorM3, .errorM2, .errorS1,
.warningM6, .warningM4, .warningM3, .warningM2, .warningS1 {
	border-color: #EF7C00;	
}

.apexp .bPageBlock .error {
    border: 2px solid #EF7C00;
}

.errorM6 h4, .errorM4 h4, .errorM3 h4, .errorM2 h4, .errorS1 h4,
.errorM6 .messageText, .errorM4 .messageText, .errorM3 .messageText, .errorM2 .messageText, 
.errorS1 .messageText, 
.errorM6 ul, .errorM4 ul, .errorM3 ul, .errorM2 ul, .errorS1 ul,
.errorM6 a, .errorM4 a, .errorM3 a, .errorM2 a, .errorS1 a,
.warningM6 h4, .warningM4 h4, .warningM3 h4, .warningM2 h4, .warningS1 h4,
.warningM6 .messageText, .warningM4 .messageText, .warningM3 .messageText, .warningM2 .messageText, 
.warningS1 .messageText, 
.warningM6 ul, .warningM4 ul, .warningM3 ul, .warningM2 ul, .warningS1 ul,
.warningM6 a, .warningM4 a, .warningM3 a, .warningM2 a, .warningS1 a
{
	color: #EF7C00 !important;	
	font-weight: bold;
}

.bPageBlock .detailList .error, .bPageTitle .tagDropDown #tag_edit_error, 
.bPageTitle .tagDropDown .tagDropDownContent .error, .tagRenameMenu .error, 
.inlineEditDiv .error, .inlineEditRequiredDiv .error {
	border: #EF7C00 solid 2px;
}


.errorStyle, .errorMsg, .importantWarning, .pbBody .errorStyle a, .pbBody .errorMsg a {
	color: #EF7C00;	
}

/* info styles */
.infoM6, .infoM4, .infoM3, .infoM2, .infoS1 {
	border-color: #0097d2;	
}

.infoM6 h4, .infoM4 h4, .infoM3 h4, .infoM2 h4, .infoS1 h4,
.infoM6 .messageText, .infoM4 .messageText, .infoM3 .messageText, .infoM2 .messageText, 
.infoS1 .messageText, 
.infoM6 ul, .infoM4 ul, .infoM3 ul, .infoM2 ul, .infoS1 ul,
.infoM6 a, .infoM4 a, .infoM3 a, .infoM2 a, .infoS1 a
{
	color: #0097d2 !important;	
	font-weight: bold;
}

.errorM6 a, .errorM4 a, .errorM3 a, .errorM2 a, .errorS1 a,
.infoM6 a, .infoM4 a, .infoM3 a, .infoM2 a, .infoS1 a,
.warningM6 a, .warningM4 a, .warningM3 a, .warningM2 a, .warningS1 a,
.errorM6 a:hover, .errorM4 a:hover, .errorM3 a:hover, .errorM2 a:hover, .errorS1 a:hover,
.infoM6 a:hover, .infoM4 a:hover, .infoM3 a:hover, .infoM2 a:hover, .infoS1 a:hover,
.warningM6 a:hover, .warningM4 a:hover, .warningM3 a:hover, .warningM2 a:hover, .warningS1 a:hover
 {
	text-decoration: underline !important;
	margin: 0 !important;	
}

/* confirm styles */
.confirmM6, .confirmM4, .confirmM3, .confirmM2, .confirmS1 {
	border-color: #5da22a;	
}

.confirmM6 h4, .confirmM4 h4, .confirmM3 h4, .confirmM2 h4, .confirmS1 h4,
.confirmM6 .messageText, .confirmM4 .messageText, .confirmM3 .messageText, .confirmM2 .messageText, 
.confirmS1 .messageText, 
.confirmM6 ul, .confirmM4 ul, .confirmM3 ul, .confirmM2 ul, .confirmS1 ul
{
	color: #5da22a;	
	font-weight: bold;
}

/* required field icon */
.bPageBlock .requiredInput .requiredBlock {
	position: absolute;
	left: -12px;
	width: 16px;
	top: 9px;
	bottom: 1px;
	background: url(PortalRequiredFieldIcon) no-repeat transparent;
}

.hideReqField .requiredBlock {
	background: none !important;	
}

/* TABLE STYLES */
.headerRowRight {
	text-align: right !important;
}

.headerRowLGBack {
	background-color: #f7f7f7;
}

.headerRowPeriod {
	padding-bottom: 2px !important;
	padding-top: 2px !important;
	width: 98px !important;
	vertical-align: middle !important;
}

.headerRowCentered {
	padding-bottom: 2px !important;
	padding-top: 2px !important;
	vertical-align: bottom !important;
	text-align: center !important;
}

.dataRowRight {
	padding-bottom: 4px !important;
	padding-top: 4px !important;
	padding-right: 5px !important;
	text-align: right !important;
}

.dataRowCentered {
	padding-bottom: 4px !important;
	padding-top: 4px !important;
	padding-right: 4px !important;
	text-align: center !important;
	vertical-align: middle !important;
}

.list .headerRow th, .list .headerRow th a {
	font-family: Calibri,"Trebuchet MS",sans-serif;			
}

/* SEW specific table styling */
.tableHeader {
	padding: 5px;
	color: #575756 !important;
	background-color: #F8FCFF;
	font-size: 15px;
	font-family: Calibri,"Trebuchet MS",sans-serif !important;	
	line-height: 2;
	font-weight: bold;
}

.tableHeader th {
	border: none !important;
	border-bottom: dotted 1px #F3F2F0 !important;
	padding: 10px 15px;
}

.tableRowOdd {
	background-color: transparent;	
}

.tableRowEven {
	background-color: #F8FCFF;
}

.tableRowEvenDarker {
	background-color: #D8EFF7;
}

.highlight td, .highlight th {
	background-color: #D8EFF7;
}

.tableCol {
	padding: 10px 15px !important;
	line-height: 2;
	border-bottom: dotted 1px #F3F2F0 !important;
}	

.tableHeaderEmphasise { background-color: #EFF8FD; }
.tableRowEmphasise { background-color: #F2FAFD; }

/*** INFO BOXES ***/

/* Info box with icon */
.informationBox,
.informationBoxRed,
.informationBoxNoIcon
 {
	background-repeat:no-repeat;
	background-position: 2px 2px;
	display: inline-block;
	font-weight: bold;
	padding-top: 3px;
	padding-bottom: 3px;
	padding-left: 20px;
	padding-right: 4px;
	font-size: 0.85em;
	margin-top: 4px;
	border-radius:3px;
	-webkit-border-radius:3px;
	-moz-border-radius:3px;
	-moz-box-shadow: 1px 2px 3px rgba(0, 0, 0, 0.4);
	-webkit-box-shadow: 1px 2px 3px rgba(0, 0, 0, 0.4);
	box-shadow: 1px 2px 3px rgba(0, 0, 0, 0.4);
	display:block;
	text-align: justify;
}

.informationBoxNoIcon { padding-left: 4px }

.informationBoxNoIcon,
.informationBox {
	background-color: #E5F1F8;
	border: 1px solid #005F98;
	color: #005F98;
}

.informationBox {
	background-image:url('https://c.ap1.content.force.com/servlet/servlet.ImageServer?id=015900000002SXa&oid=00D90000000KRNM');
}

.informationBoxRed {
	background-image:url('https://c.ap1.content.force.com/servlet/servlet.ImageServer?id=015900000002ZGI&oid=00D90000000KRNM');
	background-color: #FFC7CE;
	border: 1px solid #9C0006;
	color: #9C0006;
}

.informationBox ul,
.informationBoxNoIcon ul,
.informationBoxRed ul {
	list-style-type:disc;
	list-style-position:outside;
	margin-left: 0px;
	margin-top: 5px;
	margin-bottom: 5px;
	margin-right: 5px;
	padding-left: 0px;
}

.informationBox li,
.informationBoxNoIcon li,
.informationBoxRed li {
	margin:0 0 0 -20;
}

	/*** TAB BAR ***/

/* No border, always in focus */
#tabBar {
	z-index: 1;
	border: 0;
	padding-left: 4px;
}

/* blue background on tab bar and shadow */
.tabsNewBar {
	background: #0097D2;
	-moz-box-shadow: 0px 4px 5px rgba(0, 0, 0, 0.15);	
	-webkit-box-shadow: 0px 4px 5px rgba(0, 0, 0, 0.15);	
	box-shadow: 0px 4px 5px rgba(0, 0, 0, 0.15);	
}

/* Navigation bar - constrain to 950px centered */
.tabNavigation {
	margin: auto;
	width: 980px;
	background: #0097D2;
	padding: 0px 10px;
	margin-top: 10px;
}

/* Tab bar styles */
.tab td.currentTab,
.tab .currentTab,
#tabBar td,
#tabBar div,
#tabBar td.currentTab primaryPalette,
#tabBar td.last,
#tabBar td.currentTab,
#tabBar td.currentTab primaryPalette div,
#tabBar td.currentTab primaryPalette div a{
	background:none;
	border: 0;
	padding: 0;
	margin: 0;
}

/* all tabs */
#tabBar a, .subTabBar a {
	color: #fff;
	font-family: Calibri, "Trebuchet MS", sans-serif;
	font-size:12.75pt;
	display: block;
	margin: 0px;
	height: 27px;
	padding: 8px 10px 2px;
	cursor:pointer;
	text-decoration: none;
	border-right: 1px dotted #99D5ED;
}

/* active tab - dark grey on grey */
#tabBar .currentTab a {
	color: #575756;
	border-right: 0;
	font-weight: normal;
	background-color: #F3F2F0;
	-moz-border-radius-topright: 3px;
	-webkit-border-top-right-radius: 3px;
	border-top-right-radius: 3px;
	-moz-border-radius-topleft: 3px;
	-webkit-border-top-left-radius: 3px;
	border-top-left-radius: 3px;
	-moz-box-shadow:  0px -2px 1px rgba(0, 0, 0, 0.15);
	-webkit-box-shadow:  0px -2px 1px rgba(0, 0, 0, 0.15);
	box-shadow:  0px -2px 1px rgba(0, 0, 0, 0.15);
}

/* hover tab */	
#tabBar a:hover,
#tabBar .last a:hover {
	
}

/* Sub Tabs */
.subTabBar {
	border-collapse: collapse;	
}
.subTabBar a {
	color: #575756 !important;
	border-right: dotted 1px #575756;	
	padding: 8px 15px 3px;	
	text-decoration: none;
}

.subTabBar a:hover {
	color: #252525 !important;
	text-decoration: none;
}

.subTabBar .currentTab {
	background-color: #D8EFF7;
	border-right: none;
	-moz-border-radius-topright: 3px;
	-webkit-border-top-right-radius: 3px;
	border-top-right-radius: 3px;
	-moz-border-radius-topleft: 3px;
	-webkit-border-top-left-radius: 3px;
	border-top-left-radius: 3px;
	-moz-box-shadow:  0px -2px 1px rgba(0, 0, 0, 0.15);
	-webkit-box-shadow:  0px -2px 1px rgba(0, 0, 0, 0.15);
	box-shadow:  0px -2px 1px rgba(0, 0, 0, 0.15);
}

/*** SIDE BAR ***/

/* Module Header */
.sidebarModuleHeader {color: #005f98;}

/* Side bar divider */
/*
.sidebarCell {
	border-right: #005f98 solid 1px;
	padding-right: 6px;
}*/

/* Module Body */
.sidebarModuleBody { padding: 0 !important}

.nestedModule .sidebarModuleHeader {
	background-color: #005F98;
	font-size: 90%;
	color: #FFF;
}

/*** BUTTONS AND LINKS ***/
/* Custom Buttons (Light Blue (btn), Dark Blue, Green, Dark Gray */
.btn, .btnDarkBlue, .btnGreen, .btnDarkGray, .btnDisabled, .btnLightGrey, .btn,
.btnClearGreenText, .btnClearBlueText {
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
/* secondary button - for the most common buttons*/
.btn, .btnSecondary, .btnDarkBlue {
	background-color: #0097d2;
}
.btn:hover, .btnSecondary:hover, .btnDarkBlue:hover {
	background-color: #0072bc;
}

/* primary button - for the most important button on a page */
.btnPrimary, .btnGreen {
	background-color: #5da22a;
}
.btnPrimary:hover, .btnGreen:hover {
	background-color: #3f8418;
}

/* tertiary button */
.btnTertiary {
	background-color: #bdb8af;
}
.btnTertiary:hover {
	background-color: #968f83;
}

/* other colours */
.btnLightGrey, .btnLightGrey:hover {
	background-color: #e4e2dd;
	color: #575756;
}

.btnLightGrey:hover {
	background-color: #e4e2dd;
	color: #363636;
}

.btnWhite {
	background-color: #fff;
	color: #0097d2;
}

.btnWhite:hover {
	background-color: #fff;
	color: #0072bc;
}

.btnOrange, .btnOrange:hover {
	background-color: #ef7c00;
	color: #fff;
}

/* disabled buttons */
.btnDarkGray, .btnDisabled, .btnDisabled:hover {
	background-color: #3f3f3f;
}

.btnDisabled {color: #c1c1c1;}

/* buttons with arrows */
.btnWithArrow {
	background-image: url(PortalButtonNextArrow);
	background-position: right 50%; 
	background-repeat: no-repeat;
	text-align: left;
}

/* white links */
.whiteLink, a.whiteLink:hover {
	color: #fff;
}

/* no underlines on links */
a, a:hover {text-decoration:none;}

/* overrides jquery a */
.ui-widget-content a {
	color: #0097D2 !important;
}

.ui-widget-content a: hover {
	color: #0072bc !important;
}

/* darker blue for link hover state */
.pbBody a:hover, .lbBody a:hover, a:hover { color: #0072bc; }

/* button links */
.btnLink {
	color: #fff !important;
	text-decoration: none !important;
	vertical-align: text-top !important;
	padding: 3px 12px 3px 12px !important;
}

.btnLinkBlue {
	color: #0097d2 !important;
	text-decoration: none !important;
	vertical-align: text-top !important;
	padding: 3px 12px 3px 12px !important;
}

.btnLink2 {
	color: #fff !important;
	text-decoration: none !important;
	vertical-align: text-top !important;
	padding: 4px 12px 5px 12px !important;
}

/* buttons with no borders */
.btnClearGreenText, .btnClearGreenText:focus {
	background-color: transparent;
	color: #5da22a !important;
	-moz-box-shadow: none;
	-webkit-box-shadow: none;
	box-shadow: none;
}

.btnClearGreenText:hover { 	
	background-color: transparent;
	color: #3f8418 !important; }

.btnClearBlueText, .btnClearBlueText:focus {
	background-color: transparent;
	color: #0097d2 !important;
	-moz-box-shadow: none;
	-webkit-box-shadow: none;
	box-shadow: none;
}

.btnClearBlueText:hover { 	
	background-color: transparent;
	color: #0072d2 !important; }

.exportToolbarContainer {
	float:right;
	margin-top:5px
}

.exportToolbarItem {
	margin-right:5px;
}

/* Disable home tab */
#home_Tab {display:none;}

/* navigation boxes */
.navigationBox {
	margin-top:3px; 
	background: #E4E2DD; 
	border: 1px solid #BDB8AF;
	border-radius:3px;
	-webkit-border-radius:3px;
	-moz-border-radius:3px;
	-moz-box-shadow: 2px 2px 3px rgba(0, 0, 0, 0.15);
	-webkit-box-shadow: 2px 2px 3px rgba(0, 0, 0, 0.15);
	box-shadow: 2px 2px 3px rgba(0, 0, 0, 0.15);
}		

/* check box alignment */
.checkboxText {
   	top: -20px;
	position: relative;
	left: 30px;
	width: 290px;
}	
   
/* links with bullets */
a.bulletedLinkWhite, a.bulletedLinkBlue {padding-left: 17px; font-weight: bold;}

a.bulletedLinkWhite {
	background: url(ListBulletGT_White) no-repeat 0 4px transparent;
}

a.bulletedLinkBlue {
	background: url(ListBulletGT_Blue) no-repeat 0 3px transparent;
}
            
/*** Field level help ***/

.fieldHelp, .fieldHelpNoBG {
	font-weight: normal; font-size: 11.25pt;	
	display: inline-block; height:19px; width: 35px;
	top: 3px; position: relative;
	z-index: 99;
	text-align: justify;
}

.fieldHelp {
	background: url(Info_Icon_Large) no-repeat;
}

.fieldHelpLink {
	display: inline-block; top: 3px; left: 5px; position: relative;	
}

.fieldHelpLinkWithIcon {
	display: inline-block; 	
	width: 14px;
	background: url(PortalHelpIcon) 0 0 no-repeat;
	position: relative;
	height: 14px;
	float: left;
	top: 7px;
	margin-left: 3px;
}

.fieldHelpLink a {
	font-weight: bold;	
}

.fieldHelpPopup,
.fieldHelpNoPopup {
	display: none;
    font-size: 11.25pt;
    position:absolute;
    top:-1em;
    padding: 10px 15px;
    width: 200px;
    margin-left: 32px;
    background: #FBEDE0; 
    color: #575756;
	line-height: 1;
    border-radius:3px;
	-webkit-border-radius:3px;
	-moz-border-radius:3px;
    -moz-box-shadow: 3px 3px 2px rgba(0, 0, 0, 0.15);
	-webkit-box-shadow: 3px 3px 2px rgba(0, 0, 0, 0.15);
	box-shadow: 3px 3px 2px rgba(0, 0, 0, 0.15);
}

.fieldHelpNoBG .fieldHelpPopup {
	margin-left: 21px;	
}


.fieldHelpPopupHandle {
	display:none;
	background: url(PortalPopupBalloonHandle) transparent no-repeat;
	width: 13px;
	height: 21px;	
    position:absolute;
    margin-left: 20px;
}

.fieldHelpNoBG .fieldHelpPopupHandle {
	margin-left: 10px;	
}

.fieldHelp:hover span.fieldHelpPopup,
.fieldHelp:hover span.fieldHelpPopupHandle,
.fieldHelpNoPopup { 
    display:block;
}

.fieldHelp a {
	color: #0097D2 !important; vertical-align: top;
}

/*** FILTER PANELS ***/
.filterPanel {
    background-color: #D8EFF7;
    margin: 0px;
    padding: 30px 10px 20px;
}

.filterPanel td {
	padding-right: 15px;
}

.filterPanel label {
	padding: 0;
	margin-left: 2px;
	color: #575756;
	font-weight: bold;
}

/*** FULL PAGE TABLES ***/
.fullPageTableOuterDiv {
	display: block; position: relative; top: -50px; margin-bottom: -50px;
}

.fullPageTableInnerDiv {
	display: block; 
	margin:0px; padding-bottom: 30px; border-top-width: 0;
}

/*** MISC ***/
/* coloured borders */    
.borderDottedBlueBottom {border-bottom: #0097D2 dotted 1px;}
.borderDottedBlueRight {border-right: #0097D2 dotted 1px;}
.borderDottedBlueTop {border-top: #0097D2 dotted 1px;}
.borderDottedBlueLeft {border-left: #0097D2 dotted 1px;}
.borderDottedWhiteBottom {border-bottom: #FFF dotted 2px;}
.borderDottedWhiteRight {border-right: #FFF dotted 2px;}
.borderDottedWhiteTop {border-top: #FFF dotted 2px;}
.borderDottedWhiteLeft {border-left: #FFF dotted 2px;}
.borderDottedMedGreyBottom {border-bottom: #E4E2DD dotted 1px;}
.borderDottedMedGreyRight {border-right: #E4E2DD dotted 1px;}
.borderDottedMedGreyTop {border-top: #E4E2DD dotted 1px;}
.borderDottedMedGreyLeft {border-left: #E4E2DD dotted 1px;}	
.borderDottedDarkGreyBottom {border-bottom: #575756 dotted 1px;}
.borderDottedDarkGreyRight {border-right: #575756 dotted 1px;}
.borderDottedDarkGreyTop {border-top: #575756 dotted 1px;}
.borderDottedDarkGreyLeft {border-left: #575756 dotted 1px;}	

.borderSolidMedGreyAll {border: #E4E2DD solid 1px;}

/* colours */
.darkGrey { color: #252525; }
.grey { color: #575756; }
.midGrey { color: #959593; }
.darkWarmGrey {color: #E4E2DD; }
.warmGrey {color: #F3F2F0; }
.green {color: #5da22a; }
.blue {color: #0097d2; }
.midBlue {color: #99D5ED; }
.lightMidBlue {color: #eef8fd}
.lightBlue {color: #d8eef7; }
.orange {color: #ef7c00;}
.white {color: #fff; }

/* backgrounds */
.whiteBack {background-color: #fff; }

.radiusTopRight {
	-webkit-border-top-right-radius: 3px;
	-moz-border-radius-topright: 3px;
	border-top-right-radius: 3px;
}

.radiusTopLeft {
	-webkit-border-top-left-radius: 3px;
	-moz-border-radius-topleft: 3px;
	border-top-left-radius: 3px;
}

.radiusBtmRight {
	-webkit-border-bottom-right-radius: 3px;
	-moz-border-radius-bottomright: 3px;
	border-bottom-right-radius: 3px;
}

.radiusBtmLeft {
	-webkit-border-bottom-left-radius: 3px;
	-moz-border-radius-bottomleft: 3px;
	border-bottom-left-radius: 3px;
}

.radiusAll {
	border-radius:3px;
	-webkit-border-radius:3px;
	-moz-border-radius:3px;	
}

.shadowAll {
	-moz-box-shadow: 0px 1px 7px rgba(0, 0, 0, 0.15);
	-webkit-box-shadow: 0px 1px 7px rgba(0, 0, 0, 0.15);
	box-shadow: 0px 1px 7px rgba(0, 0, 0, 0.15); 
}

.shadowNone {
	-moz-box-shadow: none;
	-webkit-box-shadow: none;
	box-shadow: none; 
}

.sewRoundedCorner {
	-webkit-border-bottom-right-radius: 20px;
	-moz-border-radius-bottomright: 20px;
	border-bottom-right-radius: 20px;
	background: url(SEWRoundedCornerF3F2F0) bottom right no-repeat #fff\9;
	
}	

/* font sizes */
.smallFontSize { font-size: 11.25pt; }
.mediumFontSize { font-size: 15pt; }
.largeFontSize { font-size: 21.5pt; }

/* icons */
.listBulletGTBlue {
	background: url(ListBulletGT_Blue) no-repeat; width: 13px; height: 13px;
}

/* reset jquery */
.ui-widget button, .ui-widget input {
	font-size: 11.25pt;
}

/* jQuery specific styling */
.ui-dialog .ui-dialog-title {
	font-size: 15pt;	
}

.ui-dialog-titlebar {
	background: none;
	border: none;
}

.ui-dialog .ui-dialog-titlebar {
    border-bottom: 1px dotted #E4E2DD;
	-webkit-border-radius: 0;
	-moz-border-radius: 0;	
    border-radius: 0;
    margin: 0.2em 0.75em;
    padding: 0.2em 0;
}

/* clear floats */
.clear { clear:both }
.resetLineHeight { line-height: 1}

/* contact us */
.contactUs {
	height: 110px; top: 45%; width: 29px; z-index: 991; display: block; position: fixed; 
	text-indent: -99999px;
	box-shadow: 0px 0px 3px 3px rgba(0, 0, 0, 0.25);
    -moz-box-shadow: 0px 0px 3px 3px rgba(0, 0, 0, 0.25);
    -webkit-box-shadow: 0px 0px 3px 3px rgba(0, 0, 0, 0.25);
	-webkit-border-top-right-radius: 3px;
	-webkit-border-bottom-right-radius: 3px;
	-moz-border-radius-topright: 3px;
	-moz-border-radius-bottomright: 3px;
	border-top-right-radius: 3px;
	border-bottom-right-radius: 3px;
	background: #0072bc url(PortalContactUs) no-repeat 2px 50%;
}

/* global icons */

.helpIconSmall {
    background: url(PortalIconsStack) no-repeat -1px -136px;
    height: 45px; width: 45px;	
}

/* FAQs */
#faqDiv .helpIconSmall {
	position:relative; top: -3px;
}

#faqDiv a, #faqDiv a:hover { color: #575756; font-weight: bold; padding: 8px 2px; }
#faqDiv a:hover {cursor: pointer; color: #363636;}

