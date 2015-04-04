# ruby encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


### Profile
Profile.create({"id"=>"1", "name"=>"Jan Erik Berentsen", "phone_number"=>"99994444", "join_timestamp"=>"2015-03-25 23:33:00 UTC", "last_action_timestamp"=>"2015-03-25 23:33:00 UTC", "private_link_to_facebook"=>"", "private_link_to_linkedin"=>"", "ephemeral_answer_percent"=>"25", "profile_status_id"=>"1"})
Profile.create({"id"=>"2", "name"=>"Trygve Leite", "phone_number"=>"44449999", "join_timestamp"=>"2015-03-25 23:34:00 UTC", "last_action_timestamp"=>"2015-03-25 23:34:00 UTC", "private_link_to_facebook"=>"", "private_link_to_linkedin"=>"", "ephemeral_answer_percent"=>"75", "profile_status_id"=>""})
Profile.create({"id"=>"3", "name"=>"Fredrik", "phone_number"=>"99998888", "join_timestamp"=>"2015-03-25 23:34:00 UTC", "last_action_timestamp"=>"2015-03-25 23:34:00 UTC", "private_link_to_facebook"=>"", "private_link_to_linkedin"=>"", "ephemeral_answer_percent"=>"", "profile_status_id"=>""})
Profile.create({"id"=>"4", "name"=>"Nina", "phone_number"=>"44442222", "join_timestamp"=>"2015-03-25 23:34:00 UTC", "last_action_timestamp"=>"2015-03-25 23:34:00 UTC", "private_link_to_facebook"=>"", "private_link_to_linkedin"=>"", "ephemeral_answer_percent"=>"", "profile_status_id"=>""})
Profile.create({"id"=>"5", "name"=>"Bjarte", "phone_number"=>"95554444", "join_timestamp"=>"2015-03-25 23:35:00 UTC", "last_action_timestamp"=>"2015-03-25 23:35:00 UTC", "private_link_to_facebook"=>"", "private_link_to_linkedin"=>"", "ephemeral_answer_percent"=>"", "profile_status_id"=>""})
Profile.create({"id"=>"6", "name"=>"Kjell Einar", "phone_number"=>"99995555", "join_timestamp"=>"2015-04-04 15:45:00 UTC", "last_action_timestamp"=>"2015-04-04 15:45:00 UTC", "private_link_to_facebook"=>"", "private_link_to_linkedin"=>"", "ephemeral_answer_percent"=>"75", "profile_status_id"=>"2"})
Profile.create({"id"=>"7", "name"=>"Åse", "phone_number"=>"44441111", "join_timestamp"=>"2015-04-04 15:45:00 UTC", "last_action_timestamp"=>"2015-04-04 15:45:00 UTC", "private_link_to_facebook"=>"", "private_link_to_linkedin"=>"", "ephemeral_answer_percent"=>"95", "profile_status_id"=>"2"})
Profile.create({"id"=>"8", "name"=>"Jon Arne", "phone_number"=>"94947777", "join_timestamp"=>"2015-04-04 15:46:00 UTC", "last_action_timestamp"=>"2015-04-04 15:46:00 UTC", "private_link_to_facebook"=>"", "private_link_to_linkedin"=>"", "ephemeral_answer_percent"=>"60", "profile_status_id"=>"2"})
Profile.create({"id"=>"9", "name"=>"Ove", "phone_number"=>"99996767", "join_timestamp"=>"2015-04-04 15:47:00 UTC", "last_action_timestamp"=>"2015-04-04 15:47:00 UTC", "private_link_to_facebook"=>"", "private_link_to_linkedin"=>"", "ephemeral_answer_percent"=>"57", "profile_status_id"=>"2"})
Profile.create({"id"=>"10", "name"=>"Aina", "phone_number"=>"44448787", "join_timestamp"=>"2015-04-04 15:48:00 UTC", "last_action_timestamp"=>"2015-04-04 15:48:00 UTC", "private_link_to_facebook"=>"", "private_link_to_linkedin"=>"", "ephemeral_answer_percent"=>"100", "profile_status_id"=>"1"})
Profile.create({"id"=>"11", "name"=>"Nils", "phone_number"=>"44448888", "join_timestamp"=>"2015-04-04 15:49:00 UTC", "last_action_timestamp"=>"2015-04-04 15:49:00 UTC", "private_link_to_facebook"=>"", "private_link_to_linkedin"=>"", "ephemeral_answer_percent"=>"62", "profile_status_id"=>"2"})
Profile.create({"id"=>"12", "name"=>"Olav", "phone_number"=>"44445454", "join_timestamp"=>"2015-04-04 15:49:00 UTC", "last_action_timestamp"=>"2015-04-04 15:49:00 UTC", "private_link_to_facebook"=>"", "private_link_to_linkedin"=>"", "ephemeral_answer_percent"=>"42", "profile_status_id"=>"2"})
Profile.create({"id"=>"13", "name"=>"Eline", "phone_number"=>"44999944", "join_timestamp"=>"2015-04-04 15:50:00 UTC", "last_action_timestamp"=>"2015-04-04 15:50:00 UTC", "private_link_to_facebook"=>"", "private_link_to_linkedin"=>"", "ephemeral_answer_percent"=>"34", "profile_status_id"=>"2"})
Profile.create({"id"=>"14", "name"=>"Gunnar", "phone_number"=>"44442244", "join_timestamp"=>"2015-04-04 15:50:00 UTC", "last_action_timestamp"=>"2015-04-04 15:50:00 UTC", "private_link_to_facebook"=>"", "private_link_to_linkedin"=>"", "ephemeral_answer_percent"=>"84", "profile_status_id"=>"2"})


### ProfileStatus
ProfileStatus.create({"id"=>"1", "status"=>"WAITING_VERIFICATION"})
ProfileStatus.create({"id"=>"2", "status"=>"VERIFIED"})
ProfileStatus.create({"id"=>"3", "status"=>"ADMIN"})


### Ad
Ad.create({"id"=>"1", "profile_id"=>"1", "title"=>"Fjellpulken barnepulk med ski ", "short_description"=>"Fjellpulken barnepulk med ski ", "body"=>"Lite brukt Fjellpulken barnepulk leies ut. Pulken er komplett og har veltebøyle, vindskjerm,\r\nryggstøtte, drag og sele med kryssremmer. Overtrekkspose som gir god beskyttelse ved lagring\r\nog transport medfølger. Pulken har alltid vært lagret innendørs. Stoffet er derfor som nytt i farge.\r\nDet er ingen skader på noen deler av pulken.\r\nPå sekstitallet ble konseptet Barnepulken oppfunnet av Egil Rustadstuen, og fikk Merket for god\r\ndesign i 1968. Siden har pulken gjennomgått en stadig utvikling, men med samme grunnkonsept\r\nbasert på et båtformet glassfiberskrog.\r\nFjellpulken er et urnorsk produkt, og nyutviklingen med ski beholder den sterke identiteten. Den\r\nnye pulken er optimalisert for bruk i skiløyper, med bedre ergonomi og sikkerhet for barnet.\r\nFormgivingen er svært appellerende og ergonomien gir friere bruksmuligheter med økt\r\nbevegelighet. Den er mye lettere å gå med. Siden pulken er løftet opp fra bakken blir ikke bare\r\nkomforten for barnet bedre, men det blir også lettere å holde barnet varmt. Tryggheten er\r\nivaretatt med veltebøyle. Detaljene rundt innstillingene er fine, og alt i alt holder produktet en\r\nimponerende kvalitet.", "price"=>"250.0", "tags"=>"pulk,fjellpulk,ski"})
Ad.create({"id"=>"2", "profile_id"=>"2", "title"=>"Skiguard 850 skiboks", "short_description"=>"Skiguard 850 skiboks", "body"=>"Skiguard har designet en lekker, aerodynamisk og lavtliggende ny takboks. Skiguard 830 er\r\nberegnet på mindre biler med kortere tak, blant annet til en rekke mellomstore typer SUV.\r\n\r\nSkiguard er alene om å ha et buet design, for å passe perfekt til de nye takene som er blitt\r\ntrenden de senere år. Skiguard 830 er av samme design og meget buet. Dette gjør at boksen\r\nfår en optimal plassering på de fleste biler.\r\n\r\nDenne boksen er bygget på samme moderne lest som modell 860, er 214 cm lang, og har plass\r\ntil inntil 205 cm lange langrennsski.\r\n\r\nBoksen har også et nyutviklet låssystem som benyttes blant annet i modell 860.", "price"=>"199.0", "tags"=>"skiguard,ski,takboks"})
Ad.create({"id"=>"3", "profile_id"=>"5", "title"=>"THULE Dynamic 800 takboks", "short_description"=>"THULE Dynamic 800 takboks", "body"=>"Sporty, aerodynamisk strømlinjeformet design med spredningsteknologi som optimaliserer måten luften strømmen rundt boksen på, og en taknær bunn som passer perfekt på taket ditt.\u2028\r\n\r\nForhåndsinstallert Power-Click-hurtigmonteringssystem med integrert momentindikator for rask og sikker montering med kun én hånd.\u2028\r\n\r\nDobbeltsidig åpning med utvendige håndtak for praktisk montering, lasting og lossing.\u2028Sentrallåssystem gir maksimal sikkerhet. Den gripevennlige Thule Comfort-nøkkelen kan bare tas ut når alle låsene er lukket. Utformet med en fremoverlent posisjon på biltaket. Gir deg full tilgang til bagasjerommet uten konflikt med  takboksen.\u2028\r\n\r\nIntegrert matte med sklisikker overflate for ekstra sikring av lasten, som i tillegg reduserer støy.", "price"=>"229.0", "tags"=>""})
Ad.create({"id"=>"4", "profile_id"=>"1", "title"=>"Calix NORDIC LOADER", "short_description"=>"Calix NORDIC LOADER", "body"=>"Calix NORDIC Loader er en helt ny og meget lav takboks fra Calix. Boksen har et flott design og rommer hele 430 liter! Således egner den seg også godt til bagasje utover alpin- og langrennsski. Takboksen(e) er produsert i robust ABS plast som er 100% resirkulerbar. Åpning skjer sideveis fra begge sider og dette gir god tilgang til ski og utstyr.\r\n\r\nTakboksen leies ut med praktiske QuickGrip fester og integrert takbokslys.", "price"=>"270.0", "tags"=>""})
Ad.create({"id"=>"5", "profile_id"=>"2", "title"=>"Packline F 800 ABS takboks", "short_description"=>"Packline F 800 ABS takboks", "body"=>"En nedsenket og praktisk takboks med lav vekt og stor innvendig høyde. Formgitt for å romme det meste på reisen – hele 225 cm lang. Produsert i kraftig miljøvennlig ABS som er 100% resirkulerbar. Vårt nye patenterte hurtigfeste iZi2connect er kjapt og enkelt i bruk. Boksen er utstyrt med vårt patenterte åpningsmekanisme LiftOff som gir inn og utlasting fra 3 sider – samtidig!", "price"=>"249.0", "tags"=>""})


### Feedback
Feedback.create({"id"=>"1", "ad_id"=>"1", "from_profile_id"=>"3", "score"=>"50", "body"=>"En god allround pulk som både jeg og min kone lett kan dra til tross for mye bagasje! Pris,\r\nkvalitet og utleier er det ingenting å utsette på. Anbefales. "})
Feedback.create({"id"=>"2", "ad_id"=>"1", "from_profile_id"=>"4", "score"=>"50", "body"=>"Jan Erik møtte opp til avtalt tid og produktet stemte godt overens med annonsen. En fantastisk\r\ngod pulk som både minstemann og forelde var veldig fornøyd med og som vi veldig gjerne leier\r\nigjen. Anbefales til alle som ikke har plass hjemme og som samtidig ønsker en pulk av god\r\nkvalitet til en lav pris! "})
Feedback.create({"id"=>"3", "ad_id"=>"1", "from_profile_id"=>"5", "score"=>"40", "body"=>"Leter du etter en god, lett pulk av god kvalitet, er dette den må du leie. Produktet er helt i tråd\r\nmed annonse-beskrivelsen og til tross for en liten misforståelse fra min side, har jeg ingen\r\nproblem med å anbefale både Jan Erik og pulken til andre. Tommel opp! "})
Feedback.create({"id"=>"4", "ad_id"=>"2", "from_profile_id"=>"3", "score"=>"50", "body"=>"En veldig god skiboks som passet perfekt på bilen vår. Trygve hadde universalfester som vi også\r\nfikk låne uten ekstra kostnad. Fantastisk service og et veldig godt produkt. Anbefales. "})
Feedback.create({"id"=>"5", "ad_id"=>"2", "from_profile_id"=>"4", "score"=>"50", "body"=>"Vi hadde dessverre ikke mulighet til å hente boksen, men det var ingen problem for utleier. Han\r\ntok den med seg til oss og hjelp til med monteringen. Vi kommer garantert til å leie fra Trygve\r\nigjen! "})
Feedback.create({"id"=>"6", "ad_id"=>"2", "from_profile_id"=>"1", "score"=>"50", "body"=>"Anbefales da jeg ikke har noe å utsette verken på annonsen eller utleier. "})
Feedback.create({"id"=>"7", "ad_id"=>"3", "from_profile_id"=>"6", "score"=>"5", "body"=>"Her var det lite å klage på. Skiboksen satt som smurt på taket og Eivind var behjelpelig med å montere den. Terningkast 5 på både produkt og servicen til Eivind."})
Feedback.create({"id"=>"8", "ad_id"=>"3", "from_profile_id"=>"7", "score"=>"4", "body"=>"Synes det var litt knotete å montere denne boksen. Det ble oppgitt i annonsen at dette skulle være lett som bare det. Men etter ca 30 mi var den på plass og vi kunne sette avgårde mot fjellet. Eivind var uansett super som utleier og hjalp oss både med montering og avmontering."})
Feedback.create({"id"=>"9", "ad_id"=>"3", "from_profile_id"=>"8", "score"=>"5", "body"=>"Både Skiboks og «handelen» med Eivind gikk helt etter planen. Supert opplegg på alle måter!"})
Feedback.create({"id"=>"10", "ad_id"=>"4", "from_profile_id"=>"9", "score"=>"5", "body"=>"Hva skal man si annet en at måten Plendit har gjort det enkelt og trygt å leie ting på er fantastisk bra?! Skiboksen var akuratt som det stod i annonsen, Anne var på plass ute i garasjen da vi kom og betalingen gikk raskt og smidig via appen til Plendit. Blir ikke siste gang jeg bruker denne tjenesten."})
Feedback.create({"id"=>"11", "ad_id"=>"4", "from_profile_id"=>"10", "score"=>"5", "body"=>"Både skiboksen og utleier (Anne) fortjener 5 stjerner…super service og kvalitet tvers gjennom på skiboksen."})
Feedback.create({"id"=>"12", "ad_id"=>"4", "from_profile_id"=>"11", "score"=>"5", "body"=>"Ingen ting å utsette. Leier gjerne både skiboks og andre ting av Anne dersom det skulle bli aktuelt senere."})
Feedback.create({"id"=>"13", "ad_id"=>"5", "from_profile_id"=>"12", "score"=>"5", "body"=>"Skiboksen var akuratt det vi så etter. Produktet var i sa mme stand som det ble omtalt i på Plendit. Ingen problem med å anbefale Ivar og leie av denne skiboksen til andre."})
Feedback.create({"id"=>"14", "ad_id"=>"5", "from_profile_id"=>"13", "score"=>"4", "body"=>"Boksen var perfekt til den helgen vi skulle til Hemsedal. Veldig lett både å montere og ta av da vi var ferdig med å leie den den av Ivar. Hadde det ikke vært for at Ivar 15 min for sen til avtalt tidspunkt for overlevering så hadde vi gitt han 5 stjerner på ratingen."})
Feedback.create({"id"=>"15", "ad_id"=>"5", "from_profile_id"=>"14", "score"=>"5", "body"=>"Tipp topp...både skiboksen og Ivars service. Anbefales!"})


### AdItem
AdItem.create({"id"=>"1", "ad_id"=>"1"})
AdItem.create({"id"=>"2", "ad_id"=>"2"})
AdItem.create({"id"=>"3", "ad_id"=>"2"})
AdItem.create({"id"=>"4", "ad_id"=>"2"})
AdItem.create({"id"=>"5", "ad_id"=>"3"})
AdItem.create({"id"=>"6", "ad_id"=>"4"})
AdItem.create({"id"=>"7", "ad_id"=>"5"})


### Booking
Booking.create({"id"=>"1", "ad_item_id"=>"1", "from_profile_id"=>"3", "booking_status_id"=>"1", "price"=>"250.0", "booking_from"=>"2015-03-29 11:00:00 UTC", "booking_to"=>"2015-03-31 11:00:00 UTC", "first_reply_at"=>"2015-03-28 11:05:00 UTC"})


### BookingStatus
BookingStatus.create({"id"=>"1", "status"=>"WAITING_FOR_OWNER"})
BookingStatus.create({"id"=>"2", "status"=>"WAITING_FOR_REQUESTER"})
BookingStatus.create({"id"=>"3", "status"=>"ACCEPTED"})
BookingStatus.create({"id"=>"4", "status"=>"REJECTED"})
BookingStatus.create({"id"=>"5", "status"=>"CANCELLED_BY_REQUESTER"})
BookingStatus.create({"id"=>"6", "status"=>"ADM_HIDDEN"})


### Message
Message.create({"id"=>"1", "booking_id"=>"1", "from_profile_id"=>"3", "to_profile_id"=>"1", "content"=>"Hei! Lurer på om den tidspunkt passer for deg... Hvis ikke, kan du si ifra?\r\n\r\nMvh,\r\nFredrik"})
Message.create({"id"=>"2", "booking_id"=>"1", "from_profile_id"=>"1", "to_profile_id"=>"3", "content"=>"Den tidspunkt passer helt fint! Da er det bare å komme og hente.\r\n\r\nMvh,\r\nJan Erik"})


# EOF
