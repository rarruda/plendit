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


### ProfileStatus
ProfileStatus.create({"id"=>"1", "status"=>"WAITING_VERIFICATION"})
ProfileStatus.create({"id"=>"2", "status"=>"VERIFIED"})
ProfileStatus.create({"id"=>"3", "status"=>"ADMIN"})


### Ad
Ad.create({"id"=>"1", "profile_id"=>"1", "title"=>"Fjellpulken barnepulk med ski ", "short_description"=>"Fjellpulken barnepulk med ski ", "body"=>"Lite brukt Fjellpulken barnepulk leies ut. Pulken er komplett og har veltebøyle, vindskjerm,\r\nryggstøtte, drag og sele med kryssremmer. Overtrekkspose som gir god beskyttelse ved lagring\r\nog transport medfølger. Pulken har alltid vært lagret innendørs. Stoffet er derfor som nytt i farge.\r\nDet er ingen skader på noen deler av pulken.\r\nPå sekstitallet ble konseptet Barnepulken oppfunnet av Egil Rustadstuen, og fikk Merket for god\r\ndesign i 1968. Siden har pulken gjennomgått en stadig utvikling, men med samme grunnkonsept\r\nbasert på et båtformet glassfiberskrog.\r\nFjellpulken er et urnorsk produkt, og nyutviklingen med ski beholder den sterke identiteten. Den\r\nnye pulken er optimalisert for bruk i skiløyper, med bedre ergonomi og sikkerhet for barnet.\r\nFormgivingen er svært appellerende og ergonomien gir friere bruksmuligheter med økt\r\nbevegelighet. Den er mye lettere å gå med. Siden pulken er løftet opp fra bakken blir ikke bare\r\nkomforten for barnet bedre, men det blir også lettere å holde barnet varmt. Tryggheten er\r\nivaretatt med veltebøyle. Detaljene rundt innstillingene er fine, og alt i alt holder produktet en\r\nimponerende kvalitet.", "price"=>"250.0", "tags"=>"pulk,fjellpulk,ski"})
Ad.create({"id"=>"2", "profile_id"=>"2", "title"=>"Skiguard 850 skiboks", "short_description"=>"Skiguard 850 skiboks", "body"=>"Skiguard har designet en lekker, aerodynamisk og lavtliggende ny takboks. Skiguard 830 er\r\nberegnet på mindre biler med kortere tak, blant annet til en rekke mellomstore typer SUV.\r\n\r\nSkiguard er alene om å ha et buet design, for å passe perfekt til de nye takene som er blitt\r\ntrenden de senere år. Skiguard 830 er av samme design og meget buet. Dette gjør at boksen\r\nfår en optimal plassering på de fleste biler.\r\n\r\nDenne boksen er bygget på samme moderne lest som modell 860, er 214 cm lang, og har plass\r\ntil inntil 205 cm lange langrennsski.\r\n\r\nBoksen har også et nyutviklet låssystem som benyttes blant annet i modell 860.", "price"=>"199.0", "tags"=>"skiguard,ski,takboks"})


### Feedback
Feedback.create({"id"=>"1", "ad_id"=>"1", "from_profile_id"=>"3", "score"=>"50", "body"=>"En god allround pulk som både jeg og min kone lett kan dra til tross for mye bagasje! Pris,\r\nkvalitet og utleier er det ingenting å utsette på. Anbefales. "})
Feedback.create({"id"=>"2", "ad_id"=>"1", "from_profile_id"=>"4", "score"=>"50", "body"=>"Jan Erik møtte opp til avtalt tid og produktet stemte godt overens med annonsen. En fantastisk\r\ngod pulk som både minstemann og forelde var veldig fornøyd med og som vi veldig gjerne leier\r\nigjen. Anbefales til alle som ikke har plass hjemme og som samtidig ønsker en pulk av god\r\nkvalitet til en lav pris! "})
Feedback.create({"id"=>"3", "ad_id"=>"1", "from_profile_id"=>"5", "score"=>"40", "body"=>"Leter du etter en god, lett pulk av god kvalitet, er dette den må du leie. Produktet er helt i tråd\r\nmed annonse-beskrivelsen og til tross for en liten misforståelse fra min side, har jeg ingen\r\nproblem med å anbefale både Jan Erik og pulken til andre. Tommel opp! "})
Feedback.create({"id"=>"4", "ad_id"=>"2", "from_profile_id"=>"3", "score"=>"50", "body"=>"En veldig god skiboks som passet perfekt på bilen vår. Trygve hadde universalfester som vi også\r\nfikk låne uten ekstra kostnad. Fantastisk service og et veldig godt produkt. Anbefales. "})
Feedback.create({"id"=>"5", "ad_id"=>"2", "from_profile_id"=>"4", "score"=>"50", "body"=>"Vi hadde dessverre ikke mulighet til å hente boksen, men det var ingen problem for utleier. Han\r\ntok den med seg til oss og hjelp til med monteringen. Vi kommer garantert til å leie fra Trygve\r\nigjen! "})
Feedback.create({"id"=>"6", "ad_id"=>"2", "from_profile_id"=>"1", "score"=>"50", "body"=>"Anbefales da jeg ikke har noe å utsette verken på annonsen eller utleier. "})


### AdItem
AdItem.create({"id"=>"1", "ad_id"=>"1"})
AdItem.create({"id"=>"2", "ad_id"=>"2"})
AdItem.create({"id"=>"3", "ad_id"=>"2"})
AdItem.create({"id"=>"4", "ad_id"=>"2"})


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
