function show(form) {
    var str;
    var str1;
   
   		if( document.form.firstName.value == "" )
         {
            alert( "Please provide your First name!" );
            document.form.firstName.focus() ;
            return false;
            
         }
         
         if( document.form.lastName.value == "" )
         {
            alert( "Please provide your Last Name!" );
            document.form.lastName.focus() ;
            return false;
            
         }
   
          if( document.form.firstName.value !=""  && document.form.lastName.value != "")
          {
    		 var r = confirm("Press Ok to Continue");
   	    	 if (r == true) {
                str =  form.firstName.value;
                str1 = form.lastName.value;
   
   			 var table = document.getElementById("myTable");
   			 var row = table.insertRow(1);
   			 var cell1 = row.insertCell(0);
   			 var cell2 = row.insertCell(1);
   			 cell1.innerHTML = str;
   			 cell2.innerHTML = str1;
             return false;
}	
       else
       {	return false;
       }
         
}
}
