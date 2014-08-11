/*
    Type:       Test class
    Purpose:    Tests the class GoogleViz
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class GoogleViz_Test {

     public static  testmethod void test_junparsing() {
	    try_json( '{id:"A"}');
	    try_json( '{label:"NEW A"}');
	    try_json( '{type:"string"}');
	    try_json( '{type:12}');
	    try_json( '{type:true}');
	    try_json( '{type:false}');
	    try_json( '{a:[{v: "c"}, {v: 3}]}');
	 }
	 
	 public static testmethod void GoogleReferenceJSONStringTest1() {
    String googleRefernceJSONString = '{cols: [{id: "task", label: "Task", type: "string"},{id: "hours", label: "Hours per Day", type: "number"}], ' +
                                      'rows: [{c:[{v: "Work"},{v: "11"}]},{c:[{v: "Eat"},{v: "2"}]},{c:[{v: "Commute"},{v: "2"}]},' +
                                      '{c:[{v: "Watch TV"},{v: "2"}]},{c:[{v: "Sleep"},{v: "7"}]}]}';

    GoogleViz gv = new GoogleViz();

    gv.cols = new list<GoogleViz.col> {
        new GoogleViz.Col('task','Task','string'),
        new GoogleViz.Col('hours','Hours per Day','number')
    };

    GoogleViz.row r1 = new GoogleViz.row();
    r1.cells.add ( new GoogleViz.cell( 'Work' ) );
    r1.cells.add ( new GoogleViz.cell( '11' ) );
    gv.addRow( r1 );

    GoogleViz.row r2 = new GoogleViz.row();
    r2.cells.add ( new GoogleViz.cell( 'Eat' ) );
    r2.cells.add ( new GoogleViz.cell( '2' ) );
    gv.addRow( r2 );

    GoogleViz.row r3 = new GoogleViz.row();
    r3.cells.add ( new GoogleViz.cell( 'Commute' ) );
    r3.cells.add ( new GoogleViz.cell( '2' ) );
    gv.addRow( r3 );

    GoogleViz.row r4 = new GoogleViz.row();
    r4.cells.add ( new GoogleViz.cell( 'Watch TV' ) );
    r4.cells.add ( new GoogleViz.cell( '2' ) );
    gv.addRow( r4 );

    GoogleViz.row r5 = new GoogleViz.row();
    r5.cells.add ( new GoogleViz.cell( 'Sleep' ) );
    r5.cells.add ( new GoogleViz.cell( '7' ) );
    gv.addRow( r5 );

    System.assertEquals(googleRefernceJSONString, gv.toJSONString());
 }

/* Reference JSON String *adapted* from: http://code.google.com/apis/visualization/documentation/reference.html#DataTable
    {
      cols: [{id: 'A', label: 'NEW A', type: 'string'},
             {id: 'B', label: 'B-label', type: 'number'},
             {id: 'C', label: 'C-label', type: 'date'}
            ],
      rows: [{c:[{v: 'a'}, {v: 1.0}, {v: new Date(2008, 1, 28, 0, 31, 26), f: '2/28/08 12:31 AM'}]},
             {c:[{v: 'b'}, {v: 2.0}, {v: new Date(2008, 2, 30, 0, 31, 26), f: '3/30/08 12:31 AM'}]},
             {c:[{v: 'c'}, {v: 3.0}, {v: new Date(2008, 3, 30, 0, 31, 26), f: '4/30/08 12:31 AM'}]}
            ]
    }


 {c:[{v: "a"},{v: "1"},{v: new Date(2008, 1, 28, 0, 31, 26), f: "2/28/2008 12:31 AM"}]},
 {c:[{v: "b"},{v: "2"},{v: new Date(2008, 2, 30, 0, 21, 26), f: "3/30/2008 12:21 AM"}]},
 {c:[{v: "c"},{v: "3"},{v: new Date(2008, 3, 30, 0, 31, 26), f: "4/30/2008 12:31 AM"}]}]}*/

  public static testmethod void GoogleReferenceJSONStringTest2() {
    String googleRefernceJSONString = '{cols: [{id: "A", label: "NEW A", type: "string"},' +
                                              '{id: "B", label: "B-label", type: "number"},' +
                                              '{id: "C", label: "C-label", type: "date"}], ' +
                                       'rows: [{c:[{v: "a"},{v: "1"},{v: new Date(2008, 1, 28, 0, 31, 26), f: "28/02/2008 12:31 AM"}]},' +
                                              '{c:[{v: "b"},{v: "2"},{v: new Date(2008, 2, 30, 0, 31, 26), f: "30/03/2008 12:31 AM"}]},' +
                                              '{c:[{v: "c"},{v: "3"},{v: new Date(2008, 3, 30, 0, 31, 26), f: "30/04/2008 12:31 AM"}]}]}';

    GoogleViz gv = new GoogleViz();

    gv.cols = new list<GoogleViz.col> {
        new GoogleViz.Col('A','NEW A','string'),
        new GoogleViz.Col('B','B-label','number'),
        new GoogleViz.Col('C','C-label','date')
    };

    GoogleViz.row r1 = new GoogleViz.row();
    r1.cells.add ( new GoogleViz.cell( 'a' ) );
    r1.cells.add ( new GoogleViz.cell( '1' ) );
    r1.cells.add ( new GoogleViz.cell( DateTime.newInstance(2008, 2, 28, 0, 31, 26) ) );
    gv.addRow( r1 );

    GoogleViz.row r2 = new GoogleViz.row();
    r2.cells.add ( new GoogleViz.cell( 'b' ) );
    r2.cells.add ( new GoogleViz.cell( '2' ) );
    r2.cells.add ( new GoogleViz.cell( DateTime.newInstance(2008, 3, 30, 0, 31, 26) ) );
    gv.addRow( r2 );

    GoogleViz.row r3 = new GoogleViz.row();
    r3.cells.add ( new GoogleViz.cell( 'c' ) );
    r3.cells.add ( new GoogleViz.cell( '3' ) );
    r3.cells.add ( new GoogleViz.cell( DateTime.newInstance(2008, 4, 30, 0, 31, 26) ) );
    gv.addRow( r3 );

    System.assertEquals(googleRefernceJSONString, gv.toJSONString());
 }
















 public static  testmethod void escapeTest() {
    GoogleViz.row r = new GoogleViz.row();
    GoogleViz.cell cc = new GoogleViz.cell('bad\'data with \n\t control char\'s');
    GoogleViz gv = new GoogleViz();
    gv.cols = new list<GoogleViz.col> { new GoogleViz.Col('B','b','string') };
    gv.addRow(new GoogleViz.row( new list<GoogleViz.cell> {cc} ));
    string assert = '{cols: [{id: "B", label: "b", type: "string"}], rows: [{c:[{v: "baddata with  control chars"}]}]}';

    //System.debug('EXPECTED = ' + assert);
    //System.debug('ACTUAL   = ' + gv.toJSONString());

    system.assertEquals(assert, gv.toJsonString(), 'toss control and single quotes');
 }

 public static  testmethod void rowTest() {
    GoogleViz.row r = new GoogleViz.row();
    GoogleViz.cell cc = new GoogleViz.cell();
    GoogleViz.cell boo = new GoogleViz.Cell(false);
    GoogleViz.cell i = new GoogleViz.Cell(1.0);
    GoogleViz.cell d = new GoogleViz.Cell( System.today());
    GoogleViz.cell dt = new GoogleViz.Cell ( system.now() );

    system.assert( dt.toJsonString()  != null );
    GoogleViz v = new GoogleViz();
    v.cols = new list<GoogleViz.col> {
        new GoogleViz.Col('A','New at\'s \nA','t'),
        new GoogleViz.Col('B','B label','n') };

    r = new GoogleViz.row( new list<GoogleViz.cell> {boo,i} );

    v.addRow(r);
    //system.debug(v.toJSONString());

 }

 public static  testmethod void test_col() {

    GoogleViz.Col cl = new GoogleViz.Col('A');
    cl = new GoogleViz.Col('A','New A');
    cl.ctype = 'string';
    //system.debug(cl.toJsonString());
    cl = new GoogleViz.Col('A','New A','string');
    //system.debug(cl.toJsonString());

    GoogleViz gv = new GoogleViz();
    gv.cols = new list<GoogleViz.col> { new GoogleViz.Col('A','New A','string'),
         new GoogleViz.Col('B','B label','number') };

    GoogleViz.row rr = new GoogleViz.row();

    GoogleViz.cell ctmp = new GoogleViz.cell('a');

    rr.cells.add ( ctmp );
    rr.cells.add ( new GoogleViz.cell( 3, '3ish' ) ); // {v: 3.0, f: '3'}

    // {v: new Date(2008, 3, 30, 0, 31, 26), f: '4/30/08 12:31 AM'}
    rr.cells.add ( new GoogleViz.cell( Date.newInstance(2008,3,30), '4/30/08 12:31 AM' ) );

    gv.rowCollection.add( rr );

    string assert = '{cols: [{id: "A", label: "New A", type: "string"},{id: "B", label: "B label", type: "number"}], rows: [{c:[{v: "a"},{f: "3ish",v: 3},{v: new Date(2008, 2, 30, 0, 0, 0), f: "4/30/08 12:31 AM"}]}]}';
    //System.debug('EXPECTED = ' + assert);
    //System.debug('ACTUAL   = ' + gv.toJSONString());
    system.assertEquals( assert , gv.toJSONString() );

 }



 public static  testmethod void test_unparsing2() {
    JSONObject.value va = new JSONObject.value('str');
    system.assert( va.valueToString()  == '"str"' );

    system.assert(
        GoogleViz.dateToJavaScript(Date.newInstance(2008,1,30)) == 'new Date(2008, 0, 30, 0, 0, 0)',
        ' dateToJavaScript  failed' );

    system.assert( GoogleViz.dateToJavaScript( System.now()) != null);

    GoogleViz v = new GoogleViz();
    GoogleViz.Col cl = new GoogleViz.Col();
    cl.id = 'A';
    cl.label = 'NEW A';
    cl.ctype = 'string';
    //system.debug(cl);
    //system.debug(cl.toJsonString());
    string col_str = '{id: "A", label: "NEW A", type: "string"}';
    system.assert( col_str == cl.toJsonString() );

    //system.debug( jsonobject.instance( col_str ) );
 }

 // helper to parse and un parse json testing the results
 public static void try_json(string s) {
    s = s.replaceAll(' ','');
    jsonobject j = jsonobject.instance(s);
    string jstring = j.valueToString().replaceAll(' ','');
    //system.debug(s +'>>'+ jstring);
    // remove white space for the comparison
    system.assert( s == jstring, 'mis match in parsing');


 }
}