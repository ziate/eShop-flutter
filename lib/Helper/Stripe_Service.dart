import 'dart:convert';
import 'package:eshop/CheckOut.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_payment/stripe_payment.dart';

class StripeTransactionResponse {
  String message,status;
  bool success;
  StripeTransactionResponse({this.message, this.success,this.status});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String secret ;
  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };
  static init() {
    StripePayment.setOptions(
        StripeOptions(
            publishableKey: stripeId,
            merchantId: "Test",
            androidPayMode: stripeMode
        )
    );
  }

  static Future<StripeTransactionResponse> payViaExistingCard({String amount, String currency, CreditCard card}) async{
    try {
      var paymentMethod = await StripePayment.createPaymentMethod(
          PaymentMethodRequest(card: card)
      );
      var paymentIntent = await StripeService.createPaymentIntent(
          amount,
          currency
      );
      var response = await StripePayment.confirmPaymentIntent(
          PaymentIntent(
              clientSecret: paymentIntent['client_secret'],
              paymentMethodId: paymentMethod.id
          )
      );
      if (response.status == 'succeeded'||response.status == 'pending'||response.status == 'captured') {
        return new StripeTransactionResponse(
            message: 'Transaction successful',
            success: true,
            status: response.status

        );
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed',
            success: false,
            status: response.status
        );
      }
    } on PlatformException catch(err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}',
          success: false,
          status: "fail"
      );
    }
  }

  static Future<StripeTransactionResponse> payWithNewCard({String amount, String currency}) async {
    try {
      var paymentMethod = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest()
      );

      print("stripe***$amount***$currency");

      var paymentIntent = await StripeService.createPaymentIntent(
          amount,
          currency
      );


      var response = await StripePayment.confirmPaymentIntent(
          PaymentIntent(
            clientSecret: paymentIntent['client_secret'],
            paymentMethodId: paymentMethod.id,
          )
      );

      stripePayId=paymentIntent['id'];

      if (response.status == 'succeeded') {
        return new StripeTransactionResponse(
            message: 'Transaction successful',
            success: true,
            status: response.status
        );
      }
      else if (response.status == 'pending'|| response.status=="captured") {
        return new StripeTransactionResponse(
            message: 'Transaction pending',
            success: true,
            status: response.status
        );
      }

      else {
        return new StripeTransactionResponse(
            message: 'Transaction failed',
            success: false,
            status: response.status
        );
      }
    } on PlatformException catch(err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {


      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}',
          success: false,
          status: "fail"
      );
    }
  }

  static getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return new StripeTransactionResponse(
        message: message,
        success: false,
        status: "cancelled"
    );
  }

  static Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };


      var response = await http.post(
          StripeService.paymentApiUrl,
          body: body,
          headers: StripeService.headers
      );
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }
}
