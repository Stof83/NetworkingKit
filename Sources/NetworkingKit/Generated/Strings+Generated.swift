// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Si è verificato un errore. Per favore riprova più tardi!
  internal static let anErrorOccured = L10n.tr("Localizable", "an_error_occured")
  /// Errore
  internal static let error = L10n.tr("Localizable", "error")
  /// Errore di servizio
  internal static let serviceError = L10n.tr("Localizable", "service_error")

  internal enum ApiClientError {
    internal enum InvalidResponse {
      /// Il server ha restituito una risposta non valida.
      internal static let description = L10n.tr("Localizable", "api_client_error.invalid_response.description")
      /// Risposta Non Valida
      internal static let title = L10n.tr("Localizable", "api_client_error.invalid_response.title")
    }
    internal enum NetworkFailure {
      /// La richiesta non ha potuto essere completata a causa di un problema di rete.
      internal static let description = L10n.tr("Localizable", "api_client_error.network_failure.description")
      /// Errore di Rete
      internal static let title = L10n.tr("Localizable", "api_client_error.network_failure.title")
    }
    internal enum NoData {
      /// Il server non ha restituito alcun dato.
      internal static let description = L10n.tr("Localizable", "api_client_error.no_data.description")
      /// Nessun Dato
      internal static let title = L10n.tr("Localizable", "api_client_error.no_data.title")
    }
    internal enum NoResponse {
      /// Il server non ha fornito alcun dato in risposta alla richiesta.
      internal static let description = L10n.tr("Localizable", "api_client_error.no_response.description")
      /// Nessuna Risposta
      internal static let title = L10n.tr("Localizable", "api_client_error.no_response.title")
    }
    internal enum NoValidResponse {
      /// La risposta del server era vuota o non valida.
      internal static let description = L10n.tr("Localizable", "api_client_error.no_valid_response.description")
      /// Nessuna Risposta Valida
      internal static let title = L10n.tr("Localizable", "api_client_error.no_valid_response.title")
    }
    internal enum ParsingJson {
      /// C'è stato un problema durante l'elaborazione dei dati provenienti dal server.
      internal static let description = L10n.tr("Localizable", "api_client_error.parsing_json.description")
      /// Errore dati
      internal static let title = L10n.tr("Localizable", "api_client_error.parsing_json.title")
    }
    internal enum ServerErrorMessage {
      /// Il server ha fornito un messaggio di errore in risposta alla richiesta.
      internal static let description = L10n.tr("Localizable", "api_client_error.server_error_message.description")
      /// Errore del Server
      internal static let title = L10n.tr("Localizable", "api_client_error.server_error_message.title")
    }
  }

  internal enum NetworkError {
    internal enum BadResponse {
      /// È stata ricevuta una risposta non valida dal server.
      internal static let description = L10n.tr("Localizable", "networkError.bad_response.description")
      /// Risposta Non Valida
      internal static let title = L10n.tr("Localizable", "networkError.bad_response.title")
    }
    internal enum Cancelled {
      /// La richiesta è stata annullata.
      internal static let description = L10n.tr("Localizable", "networkError.cancelled.description")
      /// Richiesta Annullata
      internal static let title = L10n.tr("Localizable", "networkError.cancelled.title")
    }
    internal enum Error {
      /// Si è verificato un errore durante l'elaborazione della richiesta.
      internal static let description = L10n.tr("Localizable", "networkError.error.description")
      /// Errore nella Richiesta
      internal static let title = L10n.tr("Localizable", "networkError.error.title")
    }
    internal enum FailedResponse {
      /// Il server non ha risposto correttamente.
      internal static let description = L10n.tr("Localizable", "networkError.failed_response.description")
      /// Risposta Fallita
      internal static let title = L10n.tr("Localizable", "networkError.failed_response.title")
    }
    internal enum Generic {
      /// Si è verificato un errore imprevisto durante l'operazione di rete.
      internal static let description = L10n.tr("Localizable", "networkError.generic.description")
      /// Errore di Rete
      internal static let title = L10n.tr("Localizable", "networkError.generic.title")
    }
    internal enum InvalidResponse {
      /// Il server ha restituito una risposta non valida.
      internal static let description = L10n.tr("Localizable", "networkError.invalid_response.description")
      /// Risposta Non Valida
      internal static let title = L10n.tr("Localizable", "networkError.invalid_response.title")
    }
    internal enum NoData {
      /// Il server non ha restituito alcun dato.
      internal static let description = L10n.tr("Localizable", "networkError.no_data.description")
      /// Nessun Dato
      internal static let title = L10n.tr("Localizable", "networkError.no_data.title")
    }
    internal enum NotConnected {
      /// Si prega di verificare le impostazioni di rete.
      internal static let description = L10n.tr("Localizable", "networkError.not_connected.description")
      /// Nessuna Connessione Internet
      internal static let title = L10n.tr("Localizable", "networkError.not_connected.title")
    }
    internal enum NotFound {
      /// La risorsa richiesta non è stata trovata sul server.
      internal static let description = L10n.tr("Localizable", "networkError.not_found.description")
      /// Risorsa Non Trovata
      internal static let title = L10n.tr("Localizable", "networkError.not_found.title")
    }
    internal enum UrlGeneration {
      /// Si è verificato un errore durante la generazione della URL.
      internal static let description = L10n.tr("Localizable", "networkError.url_generation.description")
      /// Errore Generazione URL
      internal static let title = L10n.tr("Localizable", "networkError.url_generation.title")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
