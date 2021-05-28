public class UserIntegrationLoginCon{

    public String accessToken;
    public String refreshToken;
    private String code;
    public string key = '3MVG9fe4g9fhX0E57v9JKLzMhlFqlLcJslVDaz0cNac_Exhw7suQnXPgnnnhHXIGOIMBin.m_KhHFRqzmrY3R';
    public string secret = '7B6B9E29DE30C616B5198E1A74A2CD591B8EA2998C1BDA323BAEB49F57DDE146';
    public string redirect_uri = 'https://indivisual17-dev-ed--c.visualforce.com/apex/UserIntegrationLoginCustom';
    
    public UserIntegrationLoginCon(){
    
    }
    
    public void SaveToken() {
        code = ApexPages.currentPage().getParameters().get('code');
        system.debug('-=-=-=-=-=-='+code);
        //Get the access token once we have code  
        if (code != null && code !=  '') {
            system.debug('Get the access token once we have code');
            getToken();
        }
    }

    public PageReference fetchOAuthCode() { //Authenticating  
        redirect_uri = 'https://indivisual17-dev-ed--c.visualforce.com/apex/UserIntegrationLoginCustom';
        code = ApexPages.currentPage().getParameters().get('code');
        //Get the access token once we have code  
        PageReference pg;

        if (code == null || code == '') {
            pg = new PageReference(DocusignAuthUri(key, redirect_uri));
        }
        return pg;
    }

    public String DocusignAuthUri(String Clientkey, String redirect_uri) {
        String key = EncodingUtil.urlEncode(Clientkey, 'UTF - 8');
        String uri = EncodingUtil.urlEncode(redirect_uri, 'UTF - 8');
        
        String authuri = '';
        authuri = 'https://login.salesforce.com/services/oauth2/authorize?'+'client_id='+key+'&response_type=code&redirect_uri='+uri+'&state=CID';
        system.debug('-=-=-=-=-=-authuri=-='+authuri);         
        /*' & response_type = code' +
                    ' & scope = https: //www.googleapis.com/auth/drive https://www.googleapis.com/auth/drive.appdata https://www.googleapis.com/auth/drive.file'+  
                    ' & redirect_uri = '+uri +
                    ' & state = security_token % 3 D138r5719ru3e1 % 26 url % 3 Dhttps: //oa2cb.example.com/myHome&'+  
                    ' & login_hint = jsmith @example.com & '+
                    'access_type = offline'*/
        return authuri;
    }

    public void getToken() {
        /*String authString = key+':'+secret;
        Blob headerValue = Blob.valueOf(authString);
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);           
        system.debug(authHeader);*/
        //Getting access token from google  
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://login.salesforce.com/services/oauth2/token');  
        //req.setHeader('Authorization', authHeader);        
        String messageBody = 'code='+code+'&client_id='+key+'&client_secret='+secret+'&grant_type=authorization_code'+'&redirect_uri='+EncodingUtil.urlEncode(redirect_uri, 'UTF - 8');
        
        req.setBody(messageBody);
        req.setTimeout(60 * 1000);
        system.debug('-=-=-=-=-=-req=-='+req);
        system.debug('-=-=-=-=-=-messageBody=-='+messageBody);
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        system.debug('-=-=-=-=-=-res=-=');
        system.debug('-=-=-=-=-=-res=-='+res.getHeader('Location'));  
        system.debug('-=-=-=-=-=-resbody=-='+res.getBody());  
        system.debug('-=-=-=-=-=-resStatus=-='+res.getStatusCode());  
        
        while (res.getStatusCode() == 302) {
            req.setEndpoint(res.getHeader('Location'));
            res = new Http().send(req);
        }
        system.debug('-=-=-=-=-=-res=-=');
        system.debug('-=-=-=-=-=-res=-='+res.getHeader('Location'));  
        system.debug('-=-=-=-=-=-resbody=-='+res.getBody());  
        system.debug('-=-=-=-=-=-resStatus=-='+res.getStatusCode());  
        if (res.getBody() != null && res.getStatusCode() == 200) {
            //You can parse the response to get the Access token and Refresh token  
            Map < String, Object > results = (Map < String, Object > ) JSON.deserializeUntyped(res.getBody());
            //Access Token   
            if (results.get('access_token') != null) {
                accessToken = string.valueOf(results.get('access_token'));
                //googleCusSetting.Access_token__c = accessToken;
            }
            system.debug('-=-=-='+accessToken);
            
            //Refresh Token  
            if(results.get('refresh_token') != null){  
                refreshToken=string.valueOf(results.get('refresh_token'));  
                //googleCusSetting.Refresh_Token__c = refreshToken;   
            }  
            //update googleCusSetting;  
        }
    }  
    
}