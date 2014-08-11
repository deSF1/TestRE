body 
{	
  margin:0;
  padding:0;
}

/* DIV element that provides the outermost container */
#border-div 
{
  border:1px solid gray;
  background:white;
  left:0;
  right:0;
}

/* TABLE element that groups the inputbox, the busy indicator and the clear button */
#input-table
{
}

/* TD element in which inputbox resides */
#input-table-inputbox-td
{
  width:100%
}

/* TD element in which the busy indicator is displayed */
#input-table-busy-td
{
}

/* TD element in which the clear button resides */
#input-table-clear-td
{
    padding:2px;
}

/* INPUT element into which address is typed */
#InputBox
{
  width:100%;
  border:0;
  background:white;
  font-family:arial, verdana, sans-serif;
}

/* SELECT element in which a picklist of addresses is displayed */
#AddressList
{
  border-top:solid 1px gray;
  background:white;
  font-family:arial, verdana, sans-serif;
}

/* OPTION element within address list */
#AddressList option
{
}

/* DIV elements that provide containers for the final address
   and the error messages panels */
#FinalAddress, #ErrorPanel
{
  border-top:solid 1px gray;
  padding:5px;
  font-family:arial, verdana, sans-serif;
}

/* DIV element that wraps an address line */
.address-line-wrapper
{
  border:solid 1px gray;
  margin-top:3px;
  padding:2px;
}

/* INPUT element to hold a single address line */
.address-line
{
  padding:0;
  margin:0;
  border:0;
  width:100%;
  background:white;
  font-family:arial, verdana, sans-serif;
}

/* TABLE element that groups the Back and Accept buttons */
#button-table
{
  border:0;
}

/* Empty TD element used to push buttons to the right */
#button-table-left-td
{
  width:100%;
}

/* TD element that contains the Back button */
#button-table-back-td
{
  padding:3px 3px 0px 0px;
}

/* TD element that conatins the Accept button */
#button-table-accept-td
{
  padding-top:3px;
}

/* DIV element that contains the busy indicator image */
.busy-indicator
{
  text-align:center;
  width:16px;
  height:16px;
  background-image:url(PortalAjaxLoader);
  background-repeat:no-repeat;
  background-position:center;
}

/* A element that contains the clear address image */
#ClearButton
{
  width:16px;
  height:16px;
  background-image:url(jQueryIcons_0197d2_256x240);
  background-repeat:no-repeat;
  background-position: -32px -192px;
  display:inline-block;
  width:16px; height:16px;
}

/* TD element that conatins the error icon. */
#error-table-image-td
{
  width:16px;
  background-image:url(jQueryIcons_0197d2_256x240);
  background-repeat:no-repeat;
  background-position: -16px -142px;
  width:16px; height:16px;
}

/* TD element in which the error message is displayed. */
#error-table-message-td {
	font-size: 11.25pt;
}

/* Funky buttons SEW style */
#btnAccept,#btnBack {
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
	padding: 3px 8px !important;
	-moz-box-shadow: 2px 2px 3px rgba(0, 0, 0, 0.25);
	-webkit-box-shadow: 2px 2px 3px rgba(0, 0, 0, 0.25);
	box-shadow: 2px 2px 3px rgba(0, 0, 0, 0.25);
}

#btnBack {
	background-color: #0097d2;
}

#btnBack:hover {
	background-color: #0072d2;
	cursor: pointer;
}

#btnAccept {
	background-color: #5da22a;
}

#btnAccept:hover {
	background-color: #3f8418;
	cursor: pointer;
}