public with sharing class CheckDigit {
    /*
    Type:       Utility Class
    Purpose:    Calculates check digits

    ---------------------------------------------------------------
    History:

    01-Jun-2011 D.Thong (Salesforce)    Created
    24-Feb-2014 ejandusay(Cloud Sherpas) Moved test methods in a separate test class

    */

    // calculates check digit based on positional weightings from right
    public static string CalculateBAcctCheckDigit (string value){

        integer weightedSum = 0;
        string checkDigit='';
        //0. must be numeric
        if (value != null && value != '' && Pattern.matches('\\d*', value))
        {
            for (integer i = 0; i < value.length(); i++) {
                System.debug('ABC');
                System.debug(integer.valueOf(value.substring(i, i + 1)));
                System.debug(value.length()-i);
                weightedSum += (integer.valueOf(value.substring(i, i + 1))) * (value.length()-i);
            }
            System.debug('weightedsum');
            System.debug(weightedSum);
            integer remainder = math.mod(weightedSum, 11);
            integer checkdigitnumeric;
            if (remainder>0) {
                checkdigitnumeric = 11 - remainder;
                if (checkdigitnumeric == 10)
                    checkdigitnumeric = 5;
            } else
                checkdigitnumeric = 0;

            checkDigit = checkdigitnumeric.format();
        }
        return checkDigit;
    }

    
}