using Microsoft.JSInterop;

namespace WasmTemplateApp.Services;

/// <summary>
/// Provides client-side authentication using localStorage.
/// NOTE: This is a demonstration-only implementation with hardcoded credentials.
/// Do not use this pattern in production applications.
/// </summary>
public class AuthService
{
    private readonly IJSRuntime _js;
    private const string StorageKey = "auth_user";
    private const string ValidUsername = "admin";
    private const string ValidPassword = "password";

    public event Func<Task>? AuthStateChanged;

    public AuthService(IJSRuntime js) => _js = js;

    public async Task<bool> IsAuthenticatedAsync()
    {
        var user = await _js.InvokeAsync<string?>("localStorage.getItem", StorageKey);
        return !string.IsNullOrEmpty(user);
    }

    public async Task<string?> GetCurrentUserAsync()
    {
        return await _js.InvokeAsync<string?>("localStorage.getItem", StorageKey);
    }

    public async Task<bool> LoginAsync(string username, string password)
    {
        if (string.Equals(username, ValidUsername, StringComparison.Ordinal) &&
            string.Equals(password, ValidPassword, StringComparison.Ordinal))
        {
            await _js.InvokeVoidAsync("localStorage.setItem", StorageKey, username);
            await NotifyAuthStateChangedAsync();
            return true;
        }
        return false;
    }

    public async Task LogoutAsync()
    {
        await _js.InvokeVoidAsync("localStorage.removeItem", StorageKey);
        await NotifyAuthStateChangedAsync();
    }

    private async Task NotifyAuthStateChangedAsync()
    {
        if (AuthStateChanged is not null)
        {
            foreach (var handler in AuthStateChanged.GetInvocationList().Cast<Func<Task>>())
            {
                await handler();
            }
        }
    }
}
