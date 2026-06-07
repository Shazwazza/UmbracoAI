using OpenIddict.Server.AspNetCore;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.CreateUmbracoBuilder()
    .AddBackOffice()
    .AddWebsite()
    .AddComposers()
    .Build();

// Allow HTTP for local dev so Cloudflare Workers (workerd) can reach
// Umbraco's token endpoint without needing to trust a self-signed cert.
// The "Conductor" environment is a second local site (see appsettings.Conductor.json)
// used to run the Conductor workflow alongside the default Development site.
if (builder.Environment.IsDevelopment() || builder.Environment.IsEnvironment("Conductor"))
{
    builder.Services.Configure<OpenIddictServerAspNetCoreOptions>(options =>
    {
        options.DisableTransportSecurityRequirement = true;
    });
}

WebApplication app = builder.Build();


await app.BootUmbracoAsync();


app.UseUmbraco()
    .WithMiddleware(u =>
    {
        u.UseBackOffice();
        u.UseWebsite();
    })
    .WithEndpoints(u =>
    {
        u.UseBackOfficeEndpoints();
        u.UseWebsiteEndpoints();
    });

await app.RunAsync();
