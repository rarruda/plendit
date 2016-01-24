class FinancialTransactionDecorator < Draper::Decorator
  delegate_all

  # error codes from https://docs.mangopay.com/api-references/error-codes/
  def display_failure_reason
    case self.result_code
    when '101301'
      '3DSecure verifisering mislykket'
    when '101302', '101303'
      'Kortet er ikke godkjent for 3DSecure'
    when '101105'
      'Kortet har gått ut på dato'
    when '101115', '101112', '001001', '101104', '101119'
      'Ikke dekning på kortet'
    when '008999', '008001', '008002', '008003', '008004', '008005',
         '008006', '008007', '008500', '008600', '008700'
      'Sikkerhetsfeil'
    when '001011'
      'Beløpet er over maksgrensen for transaksjoner'
    when '001012'
      'Beløpet er under minimumsgrensen for transaksjoner'
    when '001013'
      'Ugyldig beløp'
    when '01101', '101102'
      'Transaksjonen ble avvist av banken'
    else
      "En ukjent feil oppstop. Feilkode #{self.result_code}"
    end
  end

end
