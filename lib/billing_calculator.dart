class BillingResult {
  final double totalCharges;
  final double finalCost;

  BillingResult({required this.totalCharges, required this.finalCost});
}

class BillingCalculator {
  static BillingResult calculate(double units, double rebatePercentage) {
    if (units < 1) units = 1;
    if (units > 1000) units = 1000;

    double totalCharges = 0.0;
    double remainingUnits = units;


    if (remainingUnits > 200) {
      totalCharges += 200 * 0.213333;
      remainingUnits -= 200;
    } else {
      totalCharges += remainingUnits * 0.213333;
      remainingUnits = 0;
    }


    if (remainingUnits > 0) {
      if (remainingUnits > 100) {
        totalCharges += 100 * 0.334;
        remainingUnits -= 100;
      } else {
        totalCharges += remainingUnits * 0.334;
        remainingUnits = 0;
      }
    }


    if (remainingUnits > 0) {
      if (remainingUnits > 300) {
        totalCharges += 300 * 0.516;
        remainingUnits -= 300;
      } else {
        totalCharges += remainingUnits * 0.516;
        remainingUnits = 0;
      }
    }


    if (remainingUnits > 0) {
      totalCharges += remainingUnits * 0.546;
    }

    double rebateAmount = totalCharges * (rebatePercentage / 100);
    double finalCost = totalCharges - rebateAmount;

    return BillingResult(
      totalCharges: totalCharges,
      finalCost: finalCost,
    );
  }
}