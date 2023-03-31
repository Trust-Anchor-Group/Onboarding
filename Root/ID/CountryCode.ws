if !Request.Encrypted then Forbidden("HTTPS access required.");

CountryCode:=IpLocale(Request.RemoteEndPoint)?.CountryCode;
PhoneCode:="";
Waher.Service.IoTBroker.Legal.Identity.PhoneCountryCodes.TryGetShortestCode((CountryCode ?? ""),PhoneCode);

{
	"RemoteEndPoint":Request.RemoteEndPoint,
	"CountryCode":CountryCode,
	"PhoneCode":"+"+PhoneCode
}