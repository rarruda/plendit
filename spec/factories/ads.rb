FactoryGirl.define do
  factory :ad do
    title         {"Fjellpulken barnepulk med ski " }
    body          {"Lite brukt Fjellpulken barnepulk leies ut. Pulken er komplett og har veltebøyle, vindskjerm,\r\nryggstøtte, drag og sele med kryssremmer. Overtrekkspose som gir god beskyttelse ved lagring\r\nog transport medfølger. Pulken har alltid vært lagret innendørs. Stoffet er derfor som nytt i farge.\r\nDet er ingen skader på noen deler av pulken.\r\nPå sekstitallet ble konseptet Barnepulken oppfunnet av Egil Rustadstuen, og fikk Merket for god\r\ndesign i 1968. Siden har pulken gjennomgått en stadig utvikling, men med samme grunnkonsept\r\nbasert på et båtformet glassfiberskrog.\r\nFjellpulken er et urnorsk produkt, og nyutviklingen med ski beholder den sterke identiteten. Den\r\nnye pulken er optimalisert for bruk i skiløyper, med bedre ergonomi og sikkerhet for barnet.\r\nFormgivingen er svært appellerende og ergonomien gir friere bruksmuligheter med økt\r\nbevegelighet. Den er mye lettere å gå med. Siden pulken er løftet opp fra bakken blir ikke bare\r\nkomforten for barnet bedre, men det blir også lettere å holde barnet varmt. Tryggheten er\r\nivaretatt med veltebøyle. Detaljene rundt innstillingene er fine, og alt i alt holder produktet en\r\nimponerende kvalitet." }

    #location
    #user
    #payin_rule

    trait :bap do
      category {"bap"}
    end
    trait :realestate do
      category {"realestate"}
    end
    trait :motor do
      category {"motor"}
      registration_number {"AA01234"}
      registration_group  {"car"}
    end
    trait :boat do
      category {"boat"}
    end

    factory :ad_bap do
      bap
    end

    factory :ad_motor do
      motor
    end

    factory :ad_realestate do
      realestate
    end

    factory :ad_boat do
      boat
      estimated_value 100_000_00
    end
  end
end