function ValidateAddress (mStreet, mStreet2, mSuburb, mState, mPostal, mCountry, IsOverseas){
              var returnmessage = "";  
	var mFullStreet, mStatePostal;	             
                                          
                if(!IsOverseas){
                    if ((trim(mStreet) == '') || (trim(mSuburb) == '') || (trim(mPostal) == '') || (trim(mCountry) == '') || (trim(mState) == '')) {
                        returnmessage = 'You must enter a value on all the required fields.';
                        return returnmessage;               
                    } 
                       
                }else{
                    if ((trim(mStreet) == '') || (trim(mCountry) == '')) {
                        returnmessage = 'You must enter a value on all the required fields.';
                        return returnmessage;               
                    } 
                }
                
                if (trim(mStreet2) != ''){
                    mFullStreet = mStreet + ', ' + mStreet2 ;                     
                } 
                else{
                    mFullStreet = mStreet;                           
                }                         
                
                               
                if(!IsOverseas){
                    if(mFullStreet.length < 4){
                        returnmessage = 'Street address cannot be less than 4 characters.';
                        return returnmessage;
                    }else if(mState.length < 2){
                        returnmessage = 'State should be 2 or more characters.';
                        return returnmessage;
                    }else if(mSuburb.length < 2){
                        returnmessage = 'Suburb should be 2 or more characters.';
                        return returnmessage;
                    }     
                }

	
                    mStatePostal = (trim(mState)).length + (trim(mPostal)).length + (trim(mSuburb)).length; 
                if (mStatePostal > 28) {
		returnmessage = 'State, Postal & Suburb should not exceed 28 characters';
		return returnmessage;
	}  
                if (trim(mStreet).length > 30){
	returnmessage = 'Street Address 1 cannot be more than 30 characters.';
                        return returnmessage;
	}
	 if (trim(mStreet2).length > 30){
	returnmessage = 'Street Address 2 cannot be more than 30 characters.';
                        return returnmessage;
	} 
	
	if(IsOverseas){
	  if(trim(mCountry).length > 30){
	returnmessage = 'Country cannot be more than 30 characters.';
	return returnmessage;
	  }
	}
	 return returnmessage;
}