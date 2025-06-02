if !Request.Encrypted and !empty(Waher.IoTGateway.Gateway.Domain) then Forbidden("HTTPS access required.");
if !exists(Posted) then BadRequest("POST expected.");

if !(Posted matches
{
	Nr:Optional(Str(PNr like "\\+[1-9]\\d+")),
	EMail:Optional(Str(PEMail like "[\\w\\d](\\w|\\d|[_\\.-][\\w\\d])*@(\\w|\\d|[\\.-][\\w\\d]+)+")),
	Resend:Optional(Bool(PResend))
}) then
	BadRequest("Invalid request.");

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

if !exists(PResend) then PResend:=false;

VerificationCode:=100000+Floor(Uniform(0,899999.9999999999999999));
IsTemporary:=false;

if !empty(PNr) then
(
	if Global.VerifyingNumbers.ContainsKey(PNr) then
	(
		if PResend then
			VerificationCode:=Global.VerifyingNumbers[PNr]
		else
			Waher.Security.LoginMonitor.LoginAuditor.Fail("Failing current Tag ID verification code and creating new.", PNr, Request.RemoteEndPoint, "HTTPS", []);
	)
	else
		PResend:=false;

	if PNr.Replace(" ","").StartsWith("+1555") then
	(
		Message:="Verification Code is available at https://"+Waher.IoTGateway.Gateway.Domain+"/ID/TestOTP.md";
		IsTemporary:=true
	)
	else
	(
		SendGatewayApiSms("NeuroAccess","Following is your verification code: " + VerificationCode,PNr);
		Message:="Verification Code sent to " + PNr + "."
	);

	if !PResend then
		Global.VerifyingNumbers[PNr]:=VerificationCode;
)
else if !empty(PEMail) then
(
	if Global.VerifyingNumbers.ContainsKey(PEMail) then
	(
		if PResend then
			VerificationCode:=Global.VerifyingNumbers[PEMail]
		else
			Waher.Security.LoginMonitor.LoginAuditor.Fail("Failing current Tag ID verification code and creating new.", PEMail, Request.RemoteEndPoint, "HTTPS", []);
	)
	else
		PResend:=false;

	AppName:=exists(Posted.AppName) ? MarkdownEncode(Posted.AppName) : "TAG Digital ID";

	SendMail(PEMail, "Verification Code", 
		"Hello\r\n"+
		"\r\n"+
		"Following is your verification code: **" + VerificationCode + "**\r\n"+
		"\r\n"+
		"This e-mail is sent to you because someone is registering this e-mail address with *" + AppName + "*.\r\n"+
		"If you have not done this, you can ignore this message. The e-mail address will not be registered.\r\n"+
		"If you initiated this registration, you will need to provide the following *verification code* into your app.\r\n"+
		"\r\n"+
		"Best regards,  \r\n"+
		"The *" + AppName + "* team\r\n"+
		"\r\n"+
		"PS: This mail is automatically generated, and any responses sent to it will be not be processed.\r\n"+
		"To cotact the *" + AppName + "* team, you need to contact the corresponding support channel."
		);

	Message:="Verification Code sent to " + PEMail + ".";

	if !PResend then
		Global.VerifyingNumbers[PEMail]:=VerificationCode;
)
else
	BadRequest("Both Phone number and e-Mail address missing.");

{
	"Status":true,
	"Message":Message,
	"IsTemporary":IsTemporary
}
