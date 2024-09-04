if !Request.Encrypted and !empty(Waher.IoTGateway.Gateway.Domain) then Forbidden("HTTPS access required.");
if !exists(Posted) then BadRequest("POST expected.");

TP := Waher.IoTGateway.Gateway.LoginAuditor.GetEarliestLoginOpportunity(Request.RemoteEndPoint, "HTTPS");

if exists(TP) then
(
	if TP = System.DateTime.MaxValue then
		Msg := "This endpoint (" + Request.RemoteEndPoint + ") has been blocked from the system."
	else
	(
		Msg := "Too many failed login attempts in a row registered. Try again after " + TP.ToLongTimeString();

		if TP.Date != Today then
		{
			if TP.Date = Today.AddDays(1) then
				Msg += " tomorrow"
			else
				Msg += ", " + TP.ToShortDateString()
		};

		Msg+="."
	);

	TooManyRequests(Msg);
);

if !exists(Global.VerifyingNumbers) then
	Global.VerifyingNumbers:=Create(Waher.Runtime.Cache.Cache,System.String,System.Double,System.Int32.MaxValue,System.TimeSpan.MaxValue,System.TimeSpan.FromHours(1));

VerificationCode:=100000+Floor(Uniform(0,899999.9999999999999999));
IsTemporary:=false;

if exists(Posted.Nr) then
(
	if !(Posted.Nr is System.String) then BadRequest("Phone number must be a string.");
	if !(Posted.Nr like "\\+[1-9]\\d+") then BadRequest("International number format expected.");

	if Global.VerifyingNumbers.ContainsKey(Posted.Nr) then
		Waher.Security.LoginMonitor.LoginAuditor.Fail("Resending Tag ID verification code.", Posted.Nr, Request.RemoteEndPoint, "HTTPS", []);

	if Posted.Nr.Replace(" ","").StartsWith("+1555") then
	(
		Message:="Verification Code is available at https://"+Waher.IoTGateway.Gateway.Domain+"/ID/TestOTP.md";
		IsTemporary:=true
	)
	else
	(
		SendGatewayApiSms("NeuroAccess","Following is your verification code: " + VerificationCode,Posted.Nr);
		Message:="Verification Code sent to " + Posted.Nr + "."
	);

	Global.VerifyingNumbers.Add(Posted.Nr,VerificationCode);
)
else if exists(Posted.EMail) then
(
	if !(Posted.EMail is System.String) then BadRequest("E-Mail must be a string.");
	if !(Posted.EMail like "[\\w\\d](\\w|\\d|[_\\.-][\\w\\d])*@(\\w|\\d|[\\.-][\\w\\d]+)+") then BadRequest("Invalid e-mail address.");

	if Global.VerifyingNumbers.ContainsKey(Posted.EMail) then
		Waher.Security.LoginMonitor.LoginAuditor.Fail("Resending Tag ID verification code.", Posted.EMail, Request.RemoteEndPoint, "HTTPS", []);

	AppName:=exists(Posted.AppName) ? MarkdownEncode(Posted.AppName) : "TAG Digital ID";

	SendMail(Posted.EMail, "Verification Code", 
		"Hello\r\n"+
		"\r\n"+
		"This e-mail is sent to you because someone is registering this e-mail address with *" + AppName + "*.\r\n"+
		"If you have not done this, you can ignore this message. The e-mail address will not be registered.\r\n"+
		"If you initiated this registration, you will need to provide the following *verification code* into your app.\r\n"+
		"\r\n"+
		"Following is your verification code: **" + VerificationCode + "**\r\n"+
		"\r\n"+
		"Best regards,  \r\n"+
		"The *" + AppName + "* team\r\n"+
		"\r\n"+
		"PS: This mail is automatically generated, and any responses sent to it will be not be processed.\r\n"+
		"To cotact the *" + AppName + "* team, you need to contact the corresponding support channel."
		);

	Message:="Verification Code sent to " + Posted.EMail + ".";

	Global.VerifyingNumbers.Add(Posted.EMail,VerificationCode);
)
else
	BadRequest("Phone number or e-Mail address missing.");

{
	"Status":true,
	"Message":Message,
	"IsTemporary":IsTemporary
}
