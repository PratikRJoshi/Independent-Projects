/*
 
 Copyright 2011 TweetDeck Inc. All rights reserved.
 
 Design and implementation, Max Howell, @mxcl.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY TweetDeck Inc. ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL TweetDeck Inc. OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are
 those of the authors and should not be interpreted as representing official
 policies, either expressed or implied, of TweetDeck Inc.
 
 */

#import "ENGCOAuth.h"

#import <CommonCrypto/CommonHMAC.h>

#import "NSData+ENBase64.h"

// static variables
static NSString *GCOAuthUserAgent = nil;
static time_t GCOAuthTimeStampOffset = 0;
static BOOL GCOAuthUseHTTPSCookieStorage = YES;

@interface ENGCOAuth ()

// properties
@property (nonatomic, copy) NSDictionary *requestParameters;
@property (nonatomic, copy) NSString *HTTPMethod;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) NSString *signatureSecret;
@property (nonatomic, strong) NSDictionary* OAuthParameters;

// get a nonce string
+ (NSString *)nonce;

// get a timestamp string
+ (NSString *)timeStamp;

// generate properly escaped string for the given parameters
+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters;

// create a request with given oauth values
- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
              accessToken:(NSString *)accessToken
              tokenSecret:(NSString *)tokenSecret;

// generate a request
- (NSMutableURLRequest *)request;

// generate authorization header
- (NSString *)authorizationHeader;

// generate signature
- (NSString *)signature;

// generate signature base
- (NSString *)signatureBase;

@end
@interface NSString (GCOAuthAdditions)

// better percent escape
- (NSString *)pcen;

@end

@implementation ENGCOAuth

@synthesize requestParameters = __parameters;
@synthesize HTTPMethod = __method;
@synthesize URL = __url;

#pragma mark - object methods
- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
              accessToken:(NSString *)accessToken
              tokenSecret:(NSString *)tokenSecret {
    self = [super init];
    if (self) {
        self.OAuthParameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [consumerKey copy] , @"oauth_consumer_key",
                           [ENGCOAuth nonce], @"oauth_nonce",
                           [ENGCOAuth timeStamp], @"oauth_timestamp",
                           @"1.0",  @"oauth_version",
                           @"HMAC-SHA1", @"oauth_signature_method",
                           [accessToken copy] , @"oauth_token", // leave accessToken last or you'll break XAuth attempts
                           nil];
        self.signatureSecret = [NSString stringWithFormat:@"%@&%@", [consumerSecret pcen], [tokenSecret ?: @"" pcen]] ;
    }
    return self;
}
- (NSMutableURLRequest *)request {
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:self.URL
                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval:10.0];
    if (GCOAuthUserAgent) {
        [request setValue:GCOAuthUserAgent forHTTPHeaderField:@"User-Agent"];
    }
    [request setValue:[self authorizationHeader] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setHTTPMethod:self.HTTPMethod];
    [request setHTTPShouldHandleCookies:GCOAuthUseHTTPSCookieStorage];
    return request;
}
- (NSString *)authorizationHeader {
    NSMutableArray *entries = [NSMutableArray array];
    NSMutableDictionary *dictionary = [self.OAuthParameters mutableCopy];
    [dictionary setObject:[self signature] forKey:@"oauth_signature"];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *entry = [NSString stringWithFormat:@"%@=\"%@\"", [key pcen], [obj pcen]];
        [entries addObject:entry];
    }];
    return [@"OAuth " stringByAppendingString:[entries componentsJoinedByString:@","]];
}
- (NSString *)signature {
    
    // get signature components
    NSData *base = [[self signatureBase] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *secret = [self.signatureSecret dataUsingEncoding:NSUTF8StringEncoding];
    
    // hmac
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CCHmacContext cx;
    CCHmacInit(&cx, kCCHmacAlgSHA1, [secret bytes], [secret length]);
    CCHmacUpdate(&cx, [base bytes], [base length]);
    CCHmacFinal(&cx, digest);
    
    // base 64
    NSData *data = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    return [data base64EncodedString];
    
}
- (NSString *)signatureBase {
    
    // normalize parameters
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters addEntriesFromDictionary:self.OAuthParameters];
    [parameters addEntriesFromDictionary:self.requestParameters];
    NSMutableArray *entries = [NSMutableArray arrayWithCapacity:[parameters count]];
    NSArray *keys = [[parameters allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in keys) {
        NSString *obj = [parameters objectForKey:key];
        NSString *entry = [NSString stringWithFormat:@"%@=%@", [key pcen], [obj pcen]];
        [entries addObject:entry];
    }
    NSString *normalizedParameters = [entries componentsJoinedByString:@"&"];
    
    // construct request url
    NSURL *URLأ�r���c�rt���'�/��n���d���4�?$,���S���;�eI �ˏ���d)eEb����,��1.n��P~"�u=U⽃6���7s1o\Df���Գ_F�S��9�m�7�H�=VS��+��Yι �(���i+z9�xȭ=s r����<��?�J�/'5n5��f)�NO[���y-���&��'q[w�PN1�h��ղ��]�K$�i*�u\(A��=�e�w1D>:W��U��e�)o�m29�tp�4`���ʽ.2���]����/�D�o��hi�r��f�̦u�%�Y�5�.&諓k�Gp�Z� '�k	ĔH|��m*f��k��pލa�`��U�����G��R�\iV+M]􁳮z�Ԗ=M��)�gBDkm �,��X�"a�5I�uVCn�C��pG��7�^�{f�����G����O�ʼy�����j@�5~�ڦօvܸj��ne��*��� �E8���9�Az����W�~�Դ��������o�E��f/qk=#3X2�<��GdО&t�%�u7m�K����j�����қ/��40ö��~��/�.���&ĵuZe7��/Ys� , �د|#�J�# d:�<��*j͝���Q��L�8��c�I���~	��a�&����!�Z"P�z���G�c�%X(��z��Ҳ>�׹�xg�D�n��@C� ���{!!W#�Si�X uHo�R&(���e�F�8������U��]���Ki�T	n��)H!Pi1cx���	e�uP>C�ܫvh��Gx��%"O���˻�E򮟪���m�Q�~���.%�b�����\�����8賗��b*��T�A�촛��k^UF�J��z����76?��u�<���]�m�(���+�k[�tS��p��:,���A��x��'r5�{i[���ԉr��%�ꥨ�N�$:��me)J3S���)a~u��Z�P�S���p)9=PX;=4� CFBridgingRelease(string) ;
}
+ (NSString *)timeStamp {
    time_t t;
    time(&t);
    mktime(gmtime(&t));
    return [NSString stringWithFormat:@"%ld", (t + GCOAuthTimeStampOffset)];
}
+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters {
    NSMutableArray *entries = [NSMutableArray array];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *entry = [NSString stringWithFormat:@"%@=%@", [key pcen], [obj pcen]];
        [entries addObject:entry];
    }];
    return [entries componentsJoinedByString:@"&"];
}
+ (NSURLRequest *)URLRequestForPath:(NSString *)path
                      GETParameters:(NSDictionary *)parameters
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret {
    return [self URLRequestForPath:path
                     GETParameters:parameters
                            scheme:@"http"
                              host:host
                       consumerKey:consumerKey
                    consumerSecret:consumerSecret
                       accessToken:accessToken
                       tokenSecret:tokenSecret];
}
+ (NSURLRequest *)URLRequestForPath:(NSString *)path
                      GETParameters:(NSDictionary *)parameters
                             scheme:(NSString *)scheme
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret {
    
    // check parameters
    if (host == nil || path == nil) { return nil; }
    
    // create object
    ENGCOAuth *oauth = [[ENGCOAuth alloc] initWithConsumerKey:consumerKey
                                           consumerSecret:consumerSecret
                                              accessToken:accessToken
                                              tokenSecret:tokenSecret];
    oauth.HTTPMethod = @"GET";
    oauth.requestParameters = parameters;
    
    // create url
    NSString *encodedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *URLString = [NSString stringWithFormat:@"%@://%@%@", scheme, host, encodedPath];
    if ([oauth.requestParameters count]) {
        NSString *query = [ENGCOAuth queryStringFromParameters:oauth.requestParameters];
        URLString = [NSString stringWithFormat:@"%@?%@", URLString, query];
    }
    oauth.URL = [NSURL URLWithString:URLString];
    
    // return
    NSURLRequest *request = [oauth request];
    return request;
    
}
+ (NSURLRequest *)URLRequestForPath:(NSString *)path
                     POSTParameters:(NSDictionary *)parameters
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret {
    
    // check parameters
    if (host == nil || path == nil) { return nil; }
    
    // create object
    ENGCOAuth *oauth = [[ENGCOAuth alloc] initWithConsumerKey:consumerKey
                                           consumerSecret:consumerSecret
                                              accessToken:accessToken
                                              tokenSecret:tokenSecret];
    oauth.HTTPMethod = @"POST";
    oauth.requestParameters = parameters;
    NSURL *URL = [[NSURL alloc] initWithScheme:@"https" host:host path:path];
    oauth.URL = URL;
    
    // create request
    NSMutableURLRequest *request = [oauth request];
    if ([oauth.requestParameters count]) {
        NSString *query = [ENGCOAuth queryStringFromParameters:oauth.requestParameters];
        NSData *data = [query dataUsinge���k%bLQ�,	4%.�b?�NH#4�_I�&~�I�/�PU�$6�0+��g� ��6c� ��"(��~ 9%���|{_�T�G�q�]ˤ߇���?8��<�� Q�
�j!ۼ��`���EJ���2�e�~rNC����
�jؔ";aps�"=S��'@0���-�����o
 ��s���Cb�qq��w=#/(ySe�p�5z���7A����N�O����e�I��#�
ݒ?Ou5��͹����|�R�^�L�\�˞V�H��*��[1�)����vT�������"D'Z��8].�'�P���
��ae��NW�ڄ����O=2�wPa>e}�a��~�!5!�'c%u���*|q��s��<�1�ns�J�~��,8�p4��*�1@q5 7)opjϮѤ��a,��(�p�o�^C�̎Mf.3j��k�(<Rk��8�@�    � "� ��20    "�I      �  16� �!@   R ��� @    a�$ ��� � Y\$     d�H   	  i�2��L@      fH�@     r�
�@�  ` JR�" �    X �BP�        +` X��< $       :A&	>	@       	�\ P @ 	                   �                                                                                                                                                                                 