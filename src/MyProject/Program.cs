using OpenIddict.Server.AspNetCore;
using Umbraco.Extensions;
using System.Linq;
using Microsoft.AspNetCore.Http;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.CreateUmbracoBuilder()
    .AddBackOffice()
    .AddWebsite()
    .AddComposers()
    .Build();

// Allow HTTP for local dev so Cloudflare Workers (workerd) can reach
// Umbraco's token endpoint without needing to trust a self-signed cert.
if (builder.Environment.IsDevelopment())
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

app.MapGet("/sitemap.xml", async (HttpContext context, Umbraco.Cms.Core.Web.IUmbracoContextFactory contextFactory, Umbraco.Cms.Web.Common.UmbracoHelper umbracoHelper) =>
{
    context.Response.ContentType = "application/xml";
    using (var umbracoContextReference = contextFactory.EnsureUmbracoContext())
    {
        var rootNodes = umbracoHelper.ContentAtRoot();
        
        var xml = new System.Text.StringBuilder();
        xml.AppendLine("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        xml.AppendLine("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\" xmlns:image=\"http://www.google.com/schemas/sitemap-image/1.1\">");

        void Traverse(Umbraco.Cms.Core.Models.PublishedContent.IPublishedContent node)
        {
            if (node == null || !node.IsVisible()) return;

            var url = node.Url(mode: Umbraco.Cms.Core.Models.PublishedContent.UrlMode.Absolute);
            
            xml.AppendLine("  <url>");
            xml.AppendLine($"    <loc>{url}</loc>");
            xml.AppendLine($"    <lastmod>{node.UpdateDate:yyyy-MM-dd}</lastmod>");
            xml.AppendLine("    <changefreq>weekly</changefreq>");
            xml.AppendLine("    <priority>0.8</priority>");

            var heroImageRaw = node.Value("heroImage");
            Umbraco.Cms.Core.Models.PublishedContent.IPublishedContent heroImage = null;
            if (heroImageRaw is Umbraco.Cms.Core.Models.PublishedContent.IPublishedContent img)
            {
                heroImage = img;
            }
            else if (heroImageRaw is IEnumerable<Umbraco.Cms.Core.Models.PublishedContent.IPublishedContent> imgList)
            {
                heroImage = imgList.FirstOrDefault();
            }

            if (heroImage != null)
            {
                var imgUrl = heroImage.Url(mode: Umbraco.Cms.Core.Models.PublishedContent.UrlMode.Absolute);
                xml.AppendLine("    <image:image>");
                xml.AppendLine($"      <image:loc>{imgUrl}</image:loc>");
                xml.AppendLine($"      <image:title>{System.Security.SecurityElement.Escape(node.Name)}</image:title>");
                xml.AppendLine("    </image:image>");
            }

            xml.AppendLine("  </url>");

            foreach (var child in node.Children())
            {
                Traverse(child);
            }
        }

        foreach (var root in rootNodes)
        {
            Traverse(root);
        }

        xml.AppendLine("</urlset>");
        await context.Response.WriteAsync(xml.ToString());
    }
});

await app.RunAsync();
