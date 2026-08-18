using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Google.Apis.Auth;
using Google.Apis.Auth.OAuth2;

namespace ServerNet;

public sealed class FcmTopicSender(HttpClient httpClient) : IDisposable
{
    private const string FirebaseMessagingScope = "https://www.googleapis.com/auth/firebase.messaging";

    private readonly HttpClient _httpClient = httpClient;

    public async Task<FcmSendResult> SendAsync(
        string serviceAccountPath,
        string topic,
        string title,
        string body,
        CancellationToken cancellationToken = default)
    {
        if (!File.Exists(serviceAccountPath))
        {
            return FcmSendResult.Failure(
                $"Service account file not found: {serviceAccountPath}");
        }

        var serviceAccountJson = await File.ReadAllTextAsync(serviceAccountPath, cancellationToken)
            .ConfigureAwait(false);

        using var document = JsonDocument.Parse(serviceAccountJson);
        var root = document.RootElement;

        if (!root.TryGetProperty("project_id", out var projectIdElement))
        {
            return FcmSendResult.Failure("Service account JSON is missing project_id.");
        }

        var projectId = projectIdElement.GetString();
        if (string.IsNullOrWhiteSpace(projectId))
        {
            return FcmSendResult.Failure("Service account JSON is missing project_id.");
        }

        try
        {
            var credential = CredentialFactory
                .FromJson(serviceAccountJson, "service_account")
                .CreateScoped(FirebaseMessagingScope);

            var accessToken = await ((ITokenAccess)credential)
                .GetAccessTokenForRequestAsync(cancellationToken: cancellationToken)
                .ConfigureAwait(false);

            var uri = new Uri($"https://fcm.googleapis.com/v1/projects/{projectId}/messages:send");
            var payload = new
            {
                message = new
                {
                    topic,
                    notification = new
                    {
                        title,
                        body,
                    },
                    data = new Dictionary<string, string>
                    {
                        ["title"] = title,
                        ["body"] = body,
                    },
                },
            };

            using var request = new HttpRequestMessage(HttpMethod.Post, uri);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            request.Content = new StringContent(
                JsonSerializer.Serialize(payload),
                Encoding.UTF8,
                "application/json");

            using var response = await _httpClient
                .SendAsync(request, cancellationToken)
                .ConfigureAwait(false);

            var responseBody = await response.Content
                .ReadAsStringAsync(cancellationToken)
                .ConfigureAwait(false);

            if ((int)response.StatusCode is >= 200 and < 300)
            {
                using var responseDocument = JsonDocument.Parse(responseBody);
                var messageName = responseDocument.RootElement.TryGetProperty("name", out var nameElement)
                    ? nameElement.GetString() ?? "(no id returned)"
                    : "(no id returned)";

                return FcmSendResult.Success(messageName);
            }

            return FcmSendResult.Failure(
                $"FCM request failed ({(int)response.StatusCode}): {responseBody}");
        }
        catch (Exception ex)
        {
            return FcmSendResult.Failure(ex.Message);
        }
    }

    public void Dispose()
    {
        _httpClient.Dispose();
    }
}
