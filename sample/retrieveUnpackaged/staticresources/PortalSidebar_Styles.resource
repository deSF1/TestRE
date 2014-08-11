
/* MAIN CONTENT CELL */
.contentCell, .contentCellDiv {
    text-align: left;
    vertical-align: top;
    width:730px;
}

/* Inner content div */
.innerContentLHSDiv {
    text-align: left;
    vertical-align: top;
    width: 460px;
    float:left;	
    padding-right: 10px;
}

.innerContentRHSDiv {
    text-align: left;
    vertical-align: top;
    width: 210px;		
    float:left;	
    border-left: #E4E2DD dotted 1px;
    padding-left: 15px;
}

/* SIDE BAR */
.sideBarCell, .sideBarCellDiv {
    text-align: left;
    vertical-align: top;
    width: 250px;
}

/* floating version */
.contentCellDiv, .sideBarCellDiv { float: left }

/* Address cell */
.contentsAddressCell {
    font-size:0.85em;
    font-weight:bold;
    color:#0A3764;
    padding-left:5px;
    padding-right:5px;
    padding-bottom:0px;
}

/* Links */
.contentsLinkCell {
    font-size:10.5pt;
    display: block;
    text-align: left;
    padding:0px;
}

.contentsLink,
.contentsLinkActive {
    height: 100%;
    padding: 8px 30px 8px 0px;
    display: block;
    text-decoration: none;
    border-style: none;
    margin-bottom: 2px;
}
.contentsLink {
    color: #575756 !important;
}

a.contentsLink {
    position: relative;
    color: #575756 !important;
    padding-left: 1px;
}

.contentsLinkActive {
    color: #0097d2 !important;
    padding-left: 1px;
}

a.contentsLinkActive {
    position: relative;
    color: #0097d2 !important;
    background: url("ListBulletGT_Blue") no-repeat scroll 95% 50%;
}

a.contentsLink:hover {
	color: #363636 !important; 
    text-decoration: none;
}

a.contentsLinkActive:hover {	
	color: #0072bc !important;
    text-decoration: none;
}

a.contentsLink span.popup, a.contentsLinkActive span.popup{display: none}

a.contentsLink:hover span.popup,
a.contentsLinkActive:hover span.popup { /*the span will display just on :hover state*/
    font-weight: bold;
    padding-top: 3px;
    padding-bottom: 3px;
    padding-left: 4px;
    padding-right: 4px;
    font-size: 8pt;
    display:block;
    position:absolute;
    top:0em; left:15em;
    background-color: #4E9F27;
    border: 1px solid #4E9F27;
    color: #fff;
    text-align: left;
    border-radius:3px;
    -webkit-border-radius:3px;
    -moz-border-radius:3px;
    -moz-box-shadow: 1px 2px 3px rgba(0, 0, 0, 0.6);
    -webkit-box-shadow: 1px 2px 3px rgba(0, 0, 0, 0.6);
    box-shadow: 1px 2px 3px rgba(0, 0, 0, 0.6);}
    