global with sharing class LinkedInManager {

    public LinkedInManager(){
        authCodeFromURL = ApexPages.currentPage().getParameters().get('code');

        if(authCodeFromURL == NULL || authCodeFromURL == ''){
            isCode=true;
        }
        else{
            isCode=false;
        }

         linkedlnInfoList=[SELECT Id, OwnerId, access_token__c, expire_in_sec__c 
                               FROM LinkedIn_Data__c where Name='LinkedlnInfo' ];


    }
    
    public Boolean isCode { get; set; }

    public String authCodeFromURL { get; set; }

    public List<LinkedIn_Data__c> linkedlnInfoList { get; set; }

    public String BasicInfo { get; set; }

    public String urlToSharedPost { get; set; }

    public String sharedInformation { get; set; }

    public Final String consumerKey='77k7d5dab515k4';

    public Final String consumerSecret='aj6hTxInyDzdwp1x';

    public Final String redirect_URI ='https://srikant-protfolio-dev-ed--c.develop.vf.force.com/apex/LinkedInvfpage';

    public String linkedln_Scope ='r_liteprofile%20r_emailaddress%20w_member_social%20w_member_social';

    public Final String linkedln_AuthUrl = 'https://www.linkedin.com/oauth/v2/authorization?';

    public Final String accessToken_Endpoint ='https://www.linkedin.com/oauth/v2/accessToken';


   

    public PageReference doGetAuthorizationCode(){

        String requestoAuthURL = linkedln_AuthUrl + 'response_type=code&client_id='+consumerKey+'&redirect_uri='+redirect_URI+

        '&state=DCEeFWf45A53sdfKef424d&scope=r_liteprofile%20r_emailaddress%20w_member_social%20w_member_social';

        PageReference pageRef = new PageReference(requestoAuthURL);

        return pageRef;

        //GET https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id={your_client_id}&redirect_uri=
        //{your_callback_url}&state=foobar&scope=r_liteprofile%20r_emailaddress%20w_member_social
    }

    public void doGetAccessToken(){

        Http http = new Http();

        HttpRequest httpReq = new HttpRequest();

        HttpResponse httpRes = new HttpResponse();

       

        String requestTokenBody = 'code='+authCodeFromURL+'&grant_type=authorization_code'+

                                    '&client_id='+consumerKey+'&client_secret='+consumerSecret+

                                    '&redirect_uri='+redirect_URI;

        String errorMessage = '';

       

        System.debug('#### authCodeFromURL '+authCodeFromURL);

        System.debug('#### requestTokenBody '+requestTokenBody);

       

        httpReq.setMethod('POST');

        httpReq.setEndpoint(accessToken_Endpoint);

        httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        httpReq.setBody(requestTokenBody);

        try{
          httpRes =http.send(httpReq);

          if(httpRes.getStatusCode()== 200){
            System.debug('Access Token Body---'+httpRes.getBody());
            Map<String,object> TokenInfo = (Map<String,object>)JSON.deserializeUntyped(httpRes.getBody());
            LinkedIn_Data__c linkedlnInfo = new LinkedIn_Data__c();

            linkedlnInfo.access_token__c =  String.valueOf(TokenInfo.get('access_token'));

            linkedlnInfo.expire_in_sec__c =  Double.valueOf(TokenInfo.get('expires_in'));

            linkedlnInfo.Name ='LinkedlnInfo';

            if(linkedlnInfoList!=null && linkedlnInfoList.size() > 0){

                linkedlnInfo.Id = linkedlnInfoList[0].Id;

            }

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,

                                         'Congrattzzzzz..... You have done successfull Integration with Linkedln'));

                upsert linkedlnInfo;

          }
          else{
            errorMessage = 'Unexpected Error while communicating with LinkedIn API. '

            +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();

ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
          }
        }catch(System.Exception e){
            System.debug('#### Exception Excuted '+e.getStackTraceString()+'  '+e.getMessage());

            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){

                errorMessage =  'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'

                                    +' Remote Site Setting and add '+' '+ accessToken_Endpoint +' Endpoint';

                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));

            }else{

                errorMessage = 'Unexpected Error while communicating with LinkedIn API. '

                                    +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();

                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));

            }

        }
    }
    
    public void doFetchBasicInfo(){

        String errorMessage ='';

        Http http = new Http();

        HttpRequest httpReq = new HttpRequest();

        HttpResponse httpRes = new HttpResponse();

       

        List<LinkedIn_Data__c> linkedlnInfoListNew = [SELECT Id, OwnerId, access_token__c, expire_in_sec__c 
        FROM LinkedIn_Data__c where Name='LinkedlnInfo' ];

       

        httpReq.SetMethod('GET');

        httpReq.setEndpoint('https://api.linkedin.com/v2/me');

        httpReq.setHeader('Authorization', 'Bearer '+linkedlnInfoListNew[0].Access_Token__c);

        httpReq.setHeader('Content-Type', 'application/json');

        try{

            httpRes=http.send(httpReq);

            if(httpRes.getStatusCode()==200){
                Map<String,object> TokenInfo = (Map<String,object>)JSON.deserializeUntyped(httpRes.getBody());

                String firstName = String.valueOf(TokenInfo.get('firstName'));

                String lastName = String.valueOf(TokenInfo.get('lastName'));

                String headline = String.valueOf(TokenInfo.get('profilePicture'));

                 String prn = String.valueOf(TokenInfo.get('id'));

                 BasicInfo = firstName +'  ' + lastName +'  '+headline+' '+prn;

                 LinkedIn_Data__c ld =new LinkedIn_Data__c(Id=linkedlnInfoListNew[0].Id,LinkedIn_User_Info__c=BasicInfo);

                 upsert ld;

            }
            else{
                errorMessage = 'Unexpected Error while communicating with LinkedIn API. '

                +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();

ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));

            }

           

            

        }catch(System.Exception e){

            System.debug('#### Exception Excuted '+e.getStackTraceString()+'  '+e.getMessage());

            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){

                errorMessage =  'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'

                                    +' Remote Site Setting and add '+' '+ 'https://api.linkedin.com/ '+' Endpoint';

                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));

            }else{

                errorMessage = 'Unexpected Error while communicating with LinkedIn API. '

                                    +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();

                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));

            }

        }

    }

    public void doSharePostOnLinkedIn(){
        String errorMessage ='';

        Http http = new Http();

        HttpRequest httpReq = new HttpRequest();

        HttpResponse httpRes = new HttpResponse();


        List<LinkedIn_Data__c> linkedlnInfoListNew = [SELECT Id, OwnerId, access_token__c, expire_in_sec__c 
        FROM LinkedIn_Data__c where Name='LinkedlnInfo'];

        httpReq.SetMethod('POST');

        httpReq.setEndpoint('https://api.linkedin.com/v2/ugcPosts');

        httpReq.setHeader('Authorization', 'Bearer '+linkedlnInfoListNew[0].Access_Token__c);

        httpReq.setHeader('Content-Type', 'application/json');

        httpReq.setHeader('x-li-format' , 'json');

        httpReq.setHeader('X-Restli-Protocol-Version' , '2.0.0');

        String requestBody = '{'+

                            '"author": "urn:li:person:8675309",'+

                            '"lifecycleState": "PUBLISHED",'+

                            ' "specificContent": {'+

                            '"com.linkedin.ugc.ShareContent": {'+

                            '"shareCommentary": {'+

                            '"text": "Looking for new opportunity as Salesforce Developer"'+

                            ' },'+

                            '"shareMediaCategory": "NONE"'+

                            '}'+

                            '},'+

                            '"visibility": {'+

                            '"com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"'+

                            '}'+

                            '}';

                            httpReq.setBody(requestBody);

                      try{
                        httpRes = http.send(httpReq);

                        if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201){
            
                            sharedInformation = requestBody;
            
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Post has been shared successfully!!'));
            
                            Map<String,object> sharedPostInformaionMap = (Map<String,object>)JSON.deserializeUntyped(httpRes.getBody());
            
                            urlToSharedPost = 'https://'+(String)sharedPostInformaionMap.get('updateUrl');
            
                           
            
                        }else{
            
                            errorMessage = 'Unexpected Error while communicating with LinkedIn API. '
            
                                                +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
            
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            
                        }

                      } catch(System.Exception  e){

                        System.debug('#### Exception Excuted '+e.getStackTraceString()+'  '+e.getMessage());

                        if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
            
                            errorMessage =  'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
            
                                                +' Remote Site Setting and add '+' '+ 'https://api.linkedin.com/ '+' Endpoint';
            
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            
                        }else{
            
                            errorMessage = 'Unexpected Error while communicating with LinkedIn API. '
            
                                                +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
            
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            
                        }

                      }     



    }

}