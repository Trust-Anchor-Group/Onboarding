if !Request.Encrypted then Forbidden("HTTPS access required.");
if !exists(Posted) then BadRequest("POST expected.");
if !exists(Posted.Code) then BadRequest("Verification code missing.");

PrevCode:=0;

if !exists(Global.VerifiedNumbers) then
	Global.VerifiedNumbers:=Create(Waher.Runtime.Cache.Cache,System.String,System.Boolean,System.Int32.MaxValue,System.TimeSpan.MaxValue,System.TimeSpan.FromDays(1));

CallerEndpoint:=Request.RemoteEndPoint;
k:=CallerEndpoint.LastIndexOf(':');
if k>0 then CallerEndpoint:=CallerEndpoint.Substring(0,k);

if exists(Posted.Nr) then
(
	if !(Posted.Nr is System.String) then BadRequest("Phone number must be a string.");
	if !(Posted.Nr like "\\+[1-9]\\d+") then BadRequest("International number format expected.");

	if !exists(Global.VerifyingNumbers) or !Global.VerifyingNumbers.TryGetValue(Posted.Nr,PrevCode) then 
		BadRequest("No pending verification code. You have to send a new verification code.");

	Global.VerifyingNumbers.Remove(Posted.Nr);

	Result := 
	{
		"Status": PrevCode=Posted.Code,
		"Temporary": Posted.Nr.Replace(" ","").StartsWith("+1555")
	};

	if Result.Status then
	(
		Global.VerifiedNumbers.Add(CallerEndpoint+"|"+Posted.Nr,true);

		Result.Message := "Mobile phone number successfully validated.";
		Waher.Security.LoginMonitor.LoginAuditor.Success(Result.Message, Posted.Nr, Request.RemoteEndPoint, "HTTPS", []);
		Region:=Posted.Nr.Substring(1,1);

		if (exists(Posted.Test) and Posted.Test) or Result.Temporary then
		(
			Result.Domain:="TBD";
			Result.Key:="TBD";
			Result.Secret:="TBD"
		)
		else if exists(Posted.App) and Posted.App="TBD" then
		(
			Result.Domain:="TBD";
			Result.Key:="TBD";
			Result.Secret:="TBD"
		)
		else if exists(Posted.App) and Posted.App="TBD" then
		(
			Result.Domain:="TBD";
			Result.Key:="TBD";
			Result.Secret:="TBD"
		)
		else
		(
			if Region="1" or Region="5" then
			(
				Result.Domain:="TBD";
				Result.Key:="TBD";
				Result.Secret:="TBD"
			)
			else if Region="2" then
			(
				Result.Domain:="TBD";
				Result.Key:="TBD";
				Result.Secret:="TBD"
			)
			else if Region="3" or Region="4" or Region="7" then
			(
				if (Posted.Nr.StartsWith("+381")) then
				(
					Result.Domain:="TBD";
					Result.Key:="TBD";
					Result.Secret:="TBD"
				)
				else
				(
					Result.Domain:="TBD";
					Result.Key:="TBD";
					Result.Secret:="TBD"
				)
			)
			else if Region="6" or Region="8" or Region="9" then
			(
				Result.Domain:="TBD";
				Result.Key:="TBD";
				Result.Secret:="TBD"
			)
		)
	)
	else
	(
		Result.Message := "Mobile phone verification code invalid.";
		Waher.Security.LoginMonitor.LoginAuditor.Fail(Result.Message, Posted.Nr, Request.RemoteEndPoint, "HTTPS", [])
	)
)
else if exists(Posted.EMail) then
(
	if !(Posted.EMail is System.String) then BadRequest("E-Mail must be a string.");
	if !(Posted.EMail like "[\\w\\d](\\w|\\d|[_\\.-][\\w\\d])*@(\\w|\\d|[\\.-][\\w\\d]+)+") then BadRequest("Invalid e-mail address.");

	if !exists(Global.VerifyingNumbers) or !Global.VerifyingNumbers.TryGetValue(Posted.EMail,PrevCode) then 
		BadRequest("No pending verification code. You have to send a new verification code.");

	Global.VerifyingNumbers.Remove(Posted.EMail);

	Result := 
	{
		"Status": PrevCode=Posted.Code
	};

	if Result.Status then
	(
		Global.VerifiedNumbers.Add(CallerEndpoint+"|"+Posted.EMail,true);

		Result.Message := "E-Mail address successfully validated.";
		Waher.Security.LoginMonitor.LoginAuditor.Success(Result.Message, Posted.EMail, Request.RemoteEndPoint, "HTTPS", [])
	)
	else
	(
		Result.Message := "E-Mail verification code invalid.";
		Waher.Security.LoginMonitor.LoginAuditor.Fail(Result.Message, Posted.EMail, Request.RemoteEndPoint, "HTTPS", [])
	)
)
else
	BadRequest("Phone number or e-Mail address missing.");

Result;
