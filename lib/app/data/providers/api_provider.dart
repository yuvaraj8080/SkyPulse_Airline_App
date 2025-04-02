import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/flight_model.dart';
import '../../utils/constants.dart';

class FlightApiProvider {
  late final Dio _dio;
  
  FlightApiProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: Constants.aviationStackBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      queryParameters: {
        'access_key': Constants.aviationStackApiKey,
      },
    ));
    
    // Add Interceptors for logging and error handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
  
  // Get real-time flight data by flight number
  Future<Flight?> getFlightByNumber(String flightNumber) async {
    try {
      final response = await _dio.get('/flights', queryParameters: {
        'flight_iata': flightNumber,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null && data['data'].isNotEmpty) {
          return Flight.fromAviationStackApi(data['data'][0]);
        }
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    } catch (e) {
      print('Error fetching flight: $e');
      return null;
    }
  }
  
  // Search flights by departure and arrival airports
  Future<List<Flight>> searchFlights({
    required String departureAirport,
    required String arrivalAirport,
    String? date,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'dep_iata': departureAirport,
        'arr_iata': arrivalAirport,
      };
      
      if (date != null) {
        queryParams['flight_date'] = date;
      }
      
      final response = await _dio.get('/flights', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          return (data['data'] as List)
              .map((flightData) => Flight.fromAviationStackApi(flightData))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      _handleError(e);
      return [];
    } catch (e) {
      print('Error searching flights: $e');
      return [];
    }
  }
  
  // Get airport information
  Future<Map<String, dynamic>?> getAirportInfo(String airportCode) async {
    try {
      final response = await _dio.get('/airports', queryParameters: {
        'iata_code': airportCode,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0];
        }
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    } catch (e) {
      print('Error fetching airport info: $e');
      return null;
    }
  }
  
  // Get airline information
  Future<Map<String, dynamic>?> getAirlineInfo(String airlineCode) async {
    try {
      final response = await _dio.get('/airlines', queryParameters: {
        'iata_code': airlineCode,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0];
        }
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    } catch (e) {
      print('Error fetching airline info: $e');
      return null;
    }
  }
  
  // Error handling helper
  void _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      print('Timeout error: ${e.message}');
    } else if (e.type == DioExceptionType.badResponse) {
      print('Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}');
      print('Response data: ${e.response?.data}');
    } else {
      print('Network error: ${e.message}');
    }
  }
}
