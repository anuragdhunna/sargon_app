import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class PdfService {
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  static Future<void> generateOrderBill(Order order, Bill? bill) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'SARGON RESTAURANT',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Order ID: ${order.id.split('_').last}'),
                  pw.Text('Date: ${_dateFormat.format(order.timestamp)}'),
                ],
              ),
              pw.Text('Table: ${order.tableNumber}'),
              if (order.guestName != null) pw.Text('Guest: ${order.guestName}'),
              if (order.waiterName != null)
                pw.Text('Waiter: ${order.waiterName}'),
              pw.Divider(),
              pw.SizedBox(height: 10),
              ...order.items.map(
                (item) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${item.quantity}x ${item.name}'),
                    pw.Text('Rs. ${item.totalPrice.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              pw.Divider(),
              if (bill != null) ...[
                _buildSummaryRow('Subtotal', bill.subTotal),
                if (bill.taxSummary.serviceChargeAmount > 0)
                  _buildSummaryRow(
                    'Service Charge',
                    bill.taxSummary.serviceChargeAmount,
                  ),
                _buildSummaryRow('CGST', bill.taxSummary.cgstAmount),
                _buildSummaryRow('SGST', bill.taxSummary.sgstAmount),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Grand Total',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Rs. ${bill.grandTotal.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ] else ...[
                _buildSummaryRow('Total', order.totalPrice),
              ],
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text('Thank You! Visit Again')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> generateConsolidatedFolio(
    String bookingId,
    List<Bill> bills,
    double posTotal,
    double totalPaid,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'SARGON HOTEL & RESTAURANT',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Consolidated Folio', style: pw.TextStyle(fontSize: 18)),
              pw.Text('Booking ID: $bookingId'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Bill ID', 'Date', 'Amount', 'Status'],
                data: bills
                    .map(
                      (b) => [
                        b.id.split('_').last,
                        _dateFormat.format(b.openedAt),
                        'Rs. ${b.grandTotal.toStringAsFixed(2)}',
                        b.paymentStatus.name.toUpperCase(),
                      ],
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              _buildSummaryRow('Total POS Charges', posTotal),
              _buildSummaryRow('Total Amount Paid', totalPaid),
              _buildSummaryRow('Remaining Balance', posTotal - totalPaid),
              pw.Divider(),
              pw.SizedBox(height: 40),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 100,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide()),
                        ),
                      ),
                      pw.Text('Guest Signature'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 100,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide()),
                        ),
                      ),
                      pw.Text('Manager Signature'),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildSummaryRow(String label, double value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(label), pw.Text('Rs. ${value.toStringAsFixed(2)}')],
      ),
    );
  }
}
