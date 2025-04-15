import 'package:flutter/material.dart';
import 'package:campus_cush_consumer/models/hostel_model.dart';

class PaymentPage extends StatefulWidget {
  final Hostel hostel;

  const PaymentPage({super.key, required this.hostel});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = 'paystack'; // Default selected method
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: const Color(0xFF1D1F33),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookingSummary(),
              const SizedBox(height: 24),
              _buildPaymentOptions(),
              const SizedBox(height: 32),
              _buildPayButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1F33),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: widget.hostel.imageUrls.isNotEmpty
                      ? Image.network(
                          widget.hostel.imageUrls[0],
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.image, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hostel.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.blueAccent, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.hostel.location,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.hostel.type,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Booking Price',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '₦${widget.hostel.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Service Fee',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '₦${(widget.hostel.price * 0.05).toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₦${(widget.hostel.price * 1.05).toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildPaymentOption(
          'paystack',
          'Paystack',
          'assets/paystack.jpg',
          'Pay with your debit card via Paystack',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          'remita',
          'Remita',
          'assets/remita.jpg',
          'Pay with Remita',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          'Google Pay',
          'Google Pay',
          'assets/google_pay.webp',
          'Pay with Google Pay',
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    String logoPath,
    String description,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _selectedPaymentMethod == value
            ? const Color(0xFF1D1F33).withOpacity(0.8)
            : const Color(0xFF1D1F33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedPaymentMethod == value
              ? Colors.blueAccent
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: RadioListTile<String>(
        title: Row(
          children: [
            SizedBox(
              width: 80,
              height: 40,
              child: Image.asset(
                logoPath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 96),
          child: Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ),
        value: value,
        groupValue: _selectedPaymentMethod,
        activeColor: Colors.blueAccent,
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blueAccent;
            }
            return Colors.white70;
          },
        ),
        onChanged: (value) {
          setState(() {
            _selectedPaymentMethod = value!;
          });
        },
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isProcessing ? null : _processPayment,
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Complete Payment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _processPayment() async {
    // Show loading state
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Process payment based on selected method
      switch (_selectedPaymentMethod) {
        case 'paystack':
          await _processPaystackPayment();
          break;
        case 'remita':
          await _processRemitaPayment();
          break;
        case 'gpay':
          await _processGPayPayment();
          break;
      }

      // For demonstration purposes, we'll just navigate to a success screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(hostel: widget.hostel),
          ),
        );
      }
    } catch (e) {
      // Handle payment error
      debugPrint('Payment error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processPaystackPayment() async {
    // Implement Paystack payment logic here
    // You would typically:
    // 1. Initialize a Paystack transaction
    // 2. Open the Paystack checkout
    // 3. Handle the callback

    // For demonstration, we're just returning success
    return Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _processRemitaPayment() async {
    // Implement Remita payment logic here
    return Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _processGPayPayment() async {
    // Implement GPay payment logic here
    return Future.delayed(const Duration(seconds: 1));
  }
}

// Create a success page for after payment completes
class PaymentSuccessPage extends StatelessWidget {
  final Hostel hostel;

  const PaymentSuccessPage({super.key, required this.hostel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You have successfully booked ${hostel.name}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Navigate back to home or bookings page
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
