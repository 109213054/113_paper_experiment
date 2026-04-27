// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract Groth16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 7762877194318453948744942803973288926645767548154260490074923363784110702163;
    uint256 constant alphay  = 21790108428873818727623116344679975939216975421114967023927949047344744407184;
    uint256 constant betax1  = 19849128922691626349401810729214534369000043624195146021874984448928913912521;
    uint256 constant betax2  = 21708626724240504669608244057043322895112046696160708568993644566413494212996;
    uint256 constant betay1  = 9995914079010231637953798299902703710717145788412227428488908150757888289583;
    uint256 constant betay2  = 4045278393883345611922436640287913011934416572131044846296528399130476871919;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 9294192177951236459323606038609011479900988869596825999937773811685223247083;
    uint256 constant deltax2 = 21768352753925163079077492217300811579467242071340748347289369151669965837000;
    uint256 constant deltay1 = 14458493610351034826570434243009649082857300546609804927132284130286849534377;
    uint256 constant deltay2 = 14786937281268257484495646641714131539440503683302322899564051134204106179601;

    
    uint256 constant IC0x = 5334178567945607780191710344068568738828874505746619879357142806870243032430;
    uint256 constant IC0y = 17677997816310448969155612843968635896370188110379420632959308556409647207386;
    
    uint256 constant IC1x = 20678996937301570555981580162338156747511384522966445855236182571461275054159;
    uint256 constant IC1y = 1591090257686213133798725670761788597823376890528384134563956978303345620473;
    
    uint256 constant IC2x = 7488314989240544261314547803557711765148534965600425380134839883645575236939;
    uint256 constant IC2y = 3641103960688965050320972963468190163528185048646831201461166011593795455628;
    
    uint256 constant IC3x = 846247485786095258487494118879387329288703645634151946511868217693045152131;
    uint256 constant IC3y = 18072354249005991184967565529171581586029696908006358013404147252763671781774;
    
    uint256 constant IC4x = 3598224272091038367609414678970740773621608731636215146410632319122643573894;
    uint256 constant IC4y = 19296785238278362513292724951278398536035608808749366168797367625203624709561;
    
    uint256 constant IC5x = 6078983229942987854130239696287128666874552657511757532773743738558033003569;
    uint256 constant IC5y = 11613835782427468779679888710110663495995679075633013078270081342141712294085;
    
    uint256 constant IC6x = 20506959316533319957309139355297898462068952572196047985879274310772749159791;
    uint256 constant IC6y = 16957939519317360825327735223014458787896153640814280233422361351311471284189;
    
    uint256 constant IC7x = 17613942371424978654714667281958516616261243244760843765544930829471094762995;
    uint256 constant IC7y = 13417875781991692371947841512604649178311876330791240502251824296407346102457;
    
    uint256 constant IC8x = 3720299449628220052203214985579290055285118315497797057821310969593160870230;
    uint256 constant IC8y = 16623383317318084827967207966071147910366375515103070755799600153928233045148;
    
    uint256 constant IC9x = 17322182310186683641941308318091522493355044070160556425706521843301107187911;
    uint256 constant IC9y = 6457855598376158838480120191479035328350064547788336463213485157783548555902;
    
    uint256 constant IC10x = 21123269262245209169916250717746150192875149862331514207640469226828273870833;
    uint256 constant IC10y = 3267351809910661539613930178837050052069494927610825519592553287338965519710;
    
    uint256 constant IC11x = 6821291273597473513032455361499348243256817022951101446695305272717923622188;
    uint256 constant IC11y = 6845719600519806817617617068703609945213284040954371635129594638669977333881;
    
    uint256 constant IC12x = 8042596645226178437946123402606184654419230079311251234605455017248468119945;
    uint256 constant IC12y = 7999070258492134159042292249542156680223091230276053313740034357036096455635;
    
    uint256 constant IC13x = 2721539100091884073176115340177668088343728462193813238174551516165507743432;
    uint256 constant IC13y = 4548916511819257108389689934538980421261440201278661633875966328039207788370;
    
    uint256 constant IC14x = 15332518960942969224770772162926020923013123607832348054258702426730660513106;
    uint256 constant IC14y = 7626291031852476345853266906726220163926168770758542860195585430154477367617;
    
    uint256 constant IC15x = 2463453016580434430177897895555455644763584116435765091321827518012717128102;
    uint256 constant IC15y = 14627044868413601519397552980742543480175507666155380487869505527069767237659;
    
    uint256 constant IC16x = 13341388672684447049400875873357326672368954824449886790488533940255530169260;
    uint256 constant IC16y = 18866951406736464779237512154831671720520322447767420099653259978059127724048;
    
    uint256 constant IC17x = 582223497008763827477367014669027563685911217336690519465126110146016563569;
    uint256 constant IC17y = 3657774995354585767755072637020639909794466910641799710600247785389716624968;
    
    uint256 constant IC18x = 11346297621195672031415074132653669851374485609230467160448504819313700406002;
    uint256 constant IC18y = 17288000867726033236694657477573640961482257939935280990571976544045751934342;
    
    uint256 constant IC19x = 167248947182883214753451366310692712030422197327066742839399219172948106121;
    uint256 constant IC19y = 16443619327186401733097978120572492829128610664790708547051121179309805901047;
    
    uint256 constant IC20x = 2438612290213521261414866872561025049083196125564081210708930888526566347311;
    uint256 constant IC20y = 3657437806117041817161467936774784839256613337071339245372097201020163878127;
    
    uint256 constant IC21x = 14959735129896707045730237721873387429467672043043075480014040481267464100439;
    uint256 constant IC21y = 19044991173066686915474514248269917794215299272830601387639989832917144221781;
    
    uint256 constant IC22x = 19997901224267979436811650947052853150088422399634041389363212008484785906001;
    uint256 constant IC22y = 2809134425474726286938411651207753230686505522752767765084657541272997454562;
    
    uint256 constant IC23x = 807798514825358138265352451471482733342647199530856358217629225291987614932;
    uint256 constant IC23y = 9321639462864338073667533166320357995589986568911180116254308834278489442880;
    
    uint256 constant IC24x = 37037541390871462055220573387035010413757932531611670833634284518307860671;
    uint256 constant IC24y = 3893957740993950820844339109910801717563445591335026453812415414377303245489;
    
    uint256 constant IC25x = 5341603554271149436773087773123145582620089105680430539070686733675576801367;
    uint256 constant IC25y = 3960341655411607062501219176034196836379186940467625929058694440702746376006;
    
    uint256 constant IC26x = 3465962757623877465805860725922864780708108724312826142106587215875972887540;
    uint256 constant IC26y = 10507451663219217210670180233728405741175243545161494662027570558168923788088;
    
    uint256 constant IC27x = 10925174672424704903192934071528748643227605834944102507183554601684857811256;
    uint256 constant IC27y = 7107312145534339009522036715526754532447245929527863982536998005942765444419;
    
    uint256 constant IC28x = 19187747318579261435475279183290637920412093472672165425881596772603563261015;
    uint256 constant IC28y = 12422725513382293172107819786071227784104476149422264891550417122319939538407;
    
    uint256 constant IC29x = 15408972428704693300890583371585210212112450680635181724542681146302075883673;
    uint256 constant IC29y = 15416343981534103478010154747577769862029110503295664867246686747586647403545;
    
    uint256 constant IC30x = 7292177887417696202258580383095922046400155243003342724150922311338986673029;
    uint256 constant IC30y = 956514688652060453544073715100403281868103566831215564408397853859295451784;
    
    uint256 constant IC31x = 15052724921167621599345571624873987121620740538875936617483916023169138548193;
    uint256 constant IC31y = 8820218527762942960230865839903196733854228167884706965567314898516945226356;
    
    uint256 constant IC32x = 5572090681211253479599427791504902091601640853584497100049840707404458069418;
    uint256 constant IC32y = 9506584048281227317005263406164303685191907540892633809668058308752106640264;
    
    uint256 constant IC33x = 20831238359544089952007343028626638221092370811350698823746189482630504982546;
    uint256 constant IC33y = 18318983375800408296809207843224617409049859698232632974827016470479785576606;
    
    uint256 constant IC34x = 17400282517352745927252971687807870683512990631628400317818751528989531362037;
    uint256 constant IC34y = 479341867148766570896198126793570906292154443082937358917392301941815624706;
    
    uint256 constant IC35x = 8599790013255765695329672496102421972431512687290981681579455315279732590849;
    uint256 constant IC35y = 21822653065824141409184792040484682606306294633100055551125792525727961391910;
    
    uint256 constant IC36x = 5386859434622629256202992682646869570767564586386871275813014036402957890707;
    uint256 constant IC36y = 20355509678734666929339729888659401666774076561402797995644929921843497089748;
    
    uint256 constant IC37x = 8546503859769644603050767865866216379304744349054944355910328194776659310973;
    uint256 constant IC37y = 6820288757277703537160393303295854629220082662342304819114889865293793142353;
    
    uint256 constant IC38x = 16504135741566782868300518634066566770325467326584999360647206116349928745337;
    uint256 constant IC38y = 5279101066011185300250738642658453481605094395321513197424672677106267508209;
    
    uint256 constant IC39x = 6319569806667004626239129829217372892860578453930212946668577393729514088816;
    uint256 constant IC39y = 5285459578088401783615689551444214849509620833038660362537260116060126945905;
    
    uint256 constant IC40x = 19813638283352809070564805295117151445794833878432932650059458509478158617550;
    uint256 constant IC40y = 15459294674257428544467925851727656772993069002937527996663402785586468460336;
    
    uint256 constant IC41x = 10390680983751220714690833908383979235335336810526114474901639575677371785936;
    uint256 constant IC41y = 17817074345970088519641735166399873474697735893195819065514724747540692386300;
    
    uint256 constant IC42x = 2931204629319749011327721561380609962583666390681708367936998673897297195000;
    uint256 constant IC42y = 12855384235313995573333028060395106982827807588197976927244618965353674453588;
    
    uint256 constant IC43x = 10815995159502839248453186425368961934164784085277656809856387563389950392780;
    uint256 constant IC43y = 78715854319920181775250003724215018096490695333458328652579451245296561177;
    
    uint256 constant IC44x = 19718525470448046305673552887727798086663911190544256236452017943318837650694;
    uint256 constant IC44y = 20609992725612884855190818159117326281420959922713639117436399684429043062007;
    
    uint256 constant IC45x = 2086241305886978774090477921871282130617992941418357085473069606633730088676;
    uint256 constant IC45y = 10551144281275269779120258749715830990473465617356132047553707037708464171847;
    
    uint256 constant IC46x = 12833431269782488013200116086367449768783293533466191116436391124902026376866;
    uint256 constant IC46y = 7011599777919837476181898513657954228478704524443017397534350877903527888209;
    
    uint256 constant IC47x = 6738715007043129584015768568503653186314607707881383860523882300627689896599;
    uint256 constant IC47y = 13441633560176269295234477362504601075718051882145154315399030144661067563487;
    
    uint256 constant IC48x = 12114652932103632637162508198854568322039408809456231607316622727383801143570;
    uint256 constant IC48y = 1644377280826890751328078578500344506248517654035001699283581786981832005228;
    
    uint256 constant IC49x = 8563702708293472519792697210851812856608878492759922053405068861862917314466;
    uint256 constant IC49y = 5490097336010148707228814071053441317185309816074501807661989523817421855777;
    
    uint256 constant IC50x = 18878552648352406122300070318666542586190119517339804214121549081243036688785;
    uint256 constant IC50y = 20278901089645535018950800536638472740664614302509538112561444655544385936949;
    
    uint256 constant IC51x = 12032355633418664975135621770647626192865829525854829976005023854195732865539;
    uint256 constant IC51y = 19302468009731309071209141700760203904908574915999729128174511617745326833062;
    
    uint256 constant IC52x = 7490837264946688809138855118261442815802238970725725261487569717587041381491;
    uint256 constant IC52y = 9278865858056700343825648567912421630995475158464302316282683956337411244562;
    
    uint256 constant IC53x = 7866988917377001828596258813329908226044977122730815787342275411875923385627;
    uint256 constant IC53y = 8653528697952647940725397803109070982554871655953684742864829277945872094128;
    
    uint256 constant IC54x = 14751577780660512439542408335512818617243652416132414716988223844388840446306;
    uint256 constant IC54y = 19475550242318566872857641017330313579965581296125596589895551203643395599230;
    
    uint256 constant IC55x = 11763926070600485751343228111256484481434554122062853911037026755492414580618;
    uint256 constant IC55y = 19958450184248445919283919842082650143517355016741356540987576107686479993723;
    
    uint256 constant IC56x = 17382660508631751842098520389165102496081582079495161983988932254092092998877;
    uint256 constant IC56y = 1340223536888617892986717940713080240879069537861220369780997689692110964313;
    
    uint256 constant IC57x = 19748929806663750814948369275956924555273620823291695027644734527424670969821;
    uint256 constant IC57y = 7274034209670391424759142323957657760433232119078485412985266597866910353444;
    
    uint256 constant IC58x = 1120486662995659852036600775711898653747058295462628324573260185835517075933;
    uint256 constant IC58y = 5857862884952777420890335322311259067665199383007357515760754363522251390192;
    
    uint256 constant IC59x = 8837008985650981582970580202620972838620937648499184269162009579434006228881;
    uint256 constant IC59y = 3195727559423942771731599620184863818843803982771325806241296973730391165403;
    
    uint256 constant IC60x = 1855755446947711788663134561645795656636411241708111961182045788011496179710;
    uint256 constant IC60y = 7542099545557857735266436850564096057652151131051579472394303308420151670621;
    
    uint256 constant IC61x = 2069980725561259453519857179175374936562479697995895052310375204413352296631;
    uint256 constant IC61y = 14680789118746381081417205230893909500467004860725979362081290177463954343328;
    
    uint256 constant IC62x = 21505906663696032839542446343618133072051742498820895225001190492182500292306;
    uint256 constant IC62y = 15962109585109930168268021672146210620117161110783859379093311211710757113754;
    
    uint256 constant IC63x = 962536369035529716458133552661036688637762688808192049624002107437906262332;
    uint256 constant IC63y = 19221316626260356422121655399424596789912595947293118181178307971059786960333;
    
    uint256 constant IC64x = 9768857992991471152244808346769080683886238747467501383067654904333566485691;
    uint256 constant IC64y = 21044995176698911549343746877407968832737998430528219112911659969960510153935;
    
    uint256 constant IC65x = 1334169576187995057005634900524074393484865380987532912653450928400444877403;
    uint256 constant IC65y = 6998604317467599994776398081232481763592280779117264513721692506790494025307;
    
    uint256 constant IC66x = 13366442654647602502235575422019346053904216653919436255538465890397135410824;
    uint256 constant IC66y = 2711447870769905137111393077861439149691189173787029798838198990077795138612;
    
    uint256 constant IC67x = 3757532733141692781979463773392587318721687397284303372564941256065925178052;
    uint256 constant IC67y = 19797154513969129594177515939771478033634789637656713915991114548180146317201;
    
    uint256 constant IC68x = 8038188886260456679938156277764318732851822351828455938373708374269866946968;
    uint256 constant IC68y = 9469803921643672471160379288593378828325275354468669901578767102128554040892;
    
    uint256 constant IC69x = 9221237268370037056413416761493090760929657806706753599889748754099642086536;
    uint256 constant IC69y = 13287364206642860780364099356654728647162102385210924855387258800495533006996;
    
    uint256 constant IC70x = 9148786431191825130677337387068344863989584666857610566703761532632050122549;
    uint256 constant IC70y = 5820202942346972518731031984804065026780932530422501740402453312662930442621;
    
    uint256 constant IC71x = 4808937621768404950173448058461107205782698293604469272172275419235487537255;
    uint256 constant IC71y = 3341796312806485801838930177153003506222623418780601846068708153223057624186;
    
    uint256 constant IC72x = 11556978257165566163054002196728036442041649266801255503961079449363710504065;
    uint256 constant IC72y = 12855222294897409294312359049461368150357014843185708913249349445658607624520;
    
    uint256 constant IC73x = 4317704593806471139803301208090308134433645380944327115200091345514437339556;
    uint256 constant IC73y = 11765504870580995266875401746923502640549339195306014028675729684802068849225;
    
    uint256 constant IC74x = 10104815995730665700674389122831507332317210249013885366129067738641689991788;
    uint256 constant IC74y = 9239184407803165808449305783083287359059729334158090488295769382326935047076;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[74] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, r)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                
                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))
                
                g1_mulAccC(_pVk, IC10x, IC10y, calldataload(add(pubSignals, 288)))
                
                g1_mulAccC(_pVk, IC11x, IC11y, calldataload(add(pubSignals, 320)))
                
                g1_mulAccC(_pVk, IC12x, IC12y, calldataload(add(pubSignals, 352)))
                
                g1_mulAccC(_pVk, IC13x, IC13y, calldataload(add(pubSignals, 384)))
                
                g1_mulAccC(_pVk, IC14x, IC14y, calldataload(add(pubSignals, 416)))
                
                g1_mulAccC(_pVk, IC15x, IC15y, calldataload(add(pubSignals, 448)))
                
                g1_mulAccC(_pVk, IC16x, IC16y, calldataload(add(pubSignals, 480)))
                
                g1_mulAccC(_pVk, IC17x, IC17y, calldataload(add(pubSignals, 512)))
                
                g1_mulAccC(_pVk, IC18x, IC18y, calldataload(add(pubSignals, 544)))
                
                g1_mulAccC(_pVk, IC19x, IC19y, calldataload(add(pubSignals, 576)))
                
                g1_mulAccC(_pVk, IC20x, IC20y, calldataload(add(pubSignals, 608)))
                
                g1_mulAccC(_pVk, IC21x, IC21y, calldataload(add(pubSignals, 640)))
                
                g1_mulAccC(_pVk, IC22x, IC22y, calldataload(add(pubSignals, 672)))
                
                g1_mulAccC(_pVk, IC23x, IC23y, calldataload(add(pubSignals, 704)))
                
                g1_mulAccC(_pVk, IC24x, IC24y, calldataload(add(pubSignals, 736)))
                
                g1_mulAccC(_pVk, IC25x, IC25y, calldataload(add(pubSignals, 768)))
                
                g1_mulAccC(_pVk, IC26x, IC26y, calldataload(add(pubSignals, 800)))
                
                g1_mulAccC(_pVk, IC27x, IC27y, calldataload(add(pubSignals, 832)))
                
                g1_mulAccC(_pVk, IC28x, IC28y, calldataload(add(pubSignals, 864)))
                
                g1_mulAccC(_pVk, IC29x, IC29y, calldataload(add(pubSignals, 896)))
                
                g1_mulAccC(_pVk, IC30x, IC30y, calldataload(add(pubSignals, 928)))
                
                g1_mulAccC(_pVk, IC31x, IC31y, calldataload(add(pubSignals, 960)))
                
                g1_mulAccC(_pVk, IC32x, IC32y, calldataload(add(pubSignals, 992)))
                
                g1_mulAccC(_pVk, IC33x, IC33y, calldataload(add(pubSignals, 1024)))
                
                g1_mulAccC(_pVk, IC34x, IC34y, calldataload(add(pubSignals, 1056)))
                
                g1_mulAccC(_pVk, IC35x, IC35y, calldataload(add(pubSignals, 1088)))
                
                g1_mulAccC(_pVk, IC36x, IC36y, calldataload(add(pubSignals, 1120)))
                
                g1_mulAccC(_pVk, IC37x, IC37y, calldataload(add(pubSignals, 1152)))
                
                g1_mulAccC(_pVk, IC38x, IC38y, calldataload(add(pubSignals, 1184)))
                
                g1_mulAccC(_pVk, IC39x, IC39y, calldataload(add(pubSignals, 1216)))
                
                g1_mulAccC(_pVk, IC40x, IC40y, calldataload(add(pubSignals, 1248)))
                
                g1_mulAccC(_pVk, IC41x, IC41y, calldataload(add(pubSignals, 1280)))
                
                g1_mulAccC(_pVk, IC42x, IC42y, calldataload(add(pubSignals, 1312)))
                
                g1_mulAccC(_pVk, IC43x, IC43y, calldataload(add(pubSignals, 1344)))
                
                g1_mulAccC(_pVk, IC44x, IC44y, calldataload(add(pubSignals, 1376)))
                
                g1_mulAccC(_pVk, IC45x, IC45y, calldataload(add(pubSignals, 1408)))
                
                g1_mulAccC(_pVk, IC46x, IC46y, calldataload(add(pubSignals, 1440)))
                
                g1_mulAccC(_pVk, IC47x, IC47y, calldataload(add(pubSignals, 1472)))
                
                g1_mulAccC(_pVk, IC48x, IC48y, calldataload(add(pubSignals, 1504)))
                
                g1_mulAccC(_pVk, IC49x, IC49y, calldataload(add(pubSignals, 1536)))
                
                g1_mulAccC(_pVk, IC50x, IC50y, calldataload(add(pubSignals, 1568)))
                
                g1_mulAccC(_pVk, IC51x, IC51y, calldataload(add(pubSignals, 1600)))
                
                g1_mulAccC(_pVk, IC52x, IC52y, calldataload(add(pubSignals, 1632)))
                
                g1_mulAccC(_pVk, IC53x, IC53y, calldataload(add(pubSignals, 1664)))
                
                g1_mulAccC(_pVk, IC54x, IC54y, calldataload(add(pubSignals, 1696)))
                
                g1_mulAccC(_pVk, IC55x, IC55y, calldataload(add(pubSignals, 1728)))
                
                g1_mulAccC(_pVk, IC56x, IC56y, calldataload(add(pubSignals, 1760)))
                
                g1_mulAccC(_pVk, IC57x, IC57y, calldataload(add(pubSignals, 1792)))
                
                g1_mulAccC(_pVk, IC58x, IC58y, calldataload(add(pubSignals, 1824)))
                
                g1_mulAccC(_pVk, IC59x, IC59y, calldataload(add(pubSignals, 1856)))
                
                g1_mulAccC(_pVk, IC60x, IC60y, calldataload(add(pubSignals, 1888)))
                
                g1_mulAccC(_pVk, IC61x, IC61y, calldataload(add(pubSignals, 1920)))
                
                g1_mulAccC(_pVk, IC62x, IC62y, calldataload(add(pubSignals, 1952)))
                
                g1_mulAccC(_pVk, IC63x, IC63y, calldataload(add(pubSignals, 1984)))
                
                g1_mulAccC(_pVk, IC64x, IC64y, calldataload(add(pubSignals, 2016)))
                
                g1_mulAccC(_pVk, IC65x, IC65y, calldataload(add(pubSignals, 2048)))
                
                g1_mulAccC(_pVk, IC66x, IC66y, calldataload(add(pubSignals, 2080)))
                
                g1_mulAccC(_pVk, IC67x, IC67y, calldataload(add(pubSignals, 2112)))
                
                g1_mulAccC(_pVk, IC68x, IC68y, calldataload(add(pubSignals, 2144)))
                
                g1_mulAccC(_pVk, IC69x, IC69y, calldataload(add(pubSignals, 2176)))
                
                g1_mulAccC(_pVk, IC70x, IC70y, calldataload(add(pubSignals, 2208)))
                
                g1_mulAccC(_pVk, IC71x, IC71y, calldataload(add(pubSignals, 2240)))
                
                g1_mulAccC(_pVk, IC72x, IC72y, calldataload(add(pubSignals, 2272)))
                
                g1_mulAccC(_pVk, IC73x, IC73y, calldataload(add(pubSignals, 2304)))
                
                g1_mulAccC(_pVk, IC74x, IC74y, calldataload(add(pubSignals, 2336)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            
            checkField(calldataload(add(_pubSignals, 288)))
            
            checkField(calldataload(add(_pubSignals, 320)))
            
            checkField(calldataload(add(_pubSignals, 352)))
            
            checkField(calldataload(add(_pubSignals, 384)))
            
            checkField(calldataload(add(_pubSignals, 416)))
            
            checkField(calldataload(add(_pubSignals, 448)))
            
            checkField(calldataload(add(_pubSignals, 480)))
            
            checkField(calldataload(add(_pubSignals, 512)))
            
            checkField(calldataload(add(_pubSignals, 544)))
            
            checkField(calldataload(add(_pubSignals, 576)))
            
            checkField(calldataload(add(_pubSignals, 608)))
            
            checkField(calldataload(add(_pubSignals, 640)))
            
            checkField(calldataload(add(_pubSignals, 672)))
            
            checkField(calldataload(add(_pubSignals, 704)))
            
            checkField(calldataload(add(_pubSignals, 736)))
            
            checkField(calldataload(add(_pubSignals, 768)))
            
            checkField(calldataload(add(_pubSignals, 800)))
            
            checkField(calldataload(add(_pubSignals, 832)))
            
            checkField(calldataload(add(_pubSignals, 864)))
            
            checkField(calldataload(add(_pubSignals, 896)))
            
            checkField(calldataload(add(_pubSignals, 928)))
            
            checkField(calldataload(add(_pubSignals, 960)))
            
            checkField(calldataload(add(_pubSignals, 992)))
            
            checkField(calldataload(add(_pubSignals, 1024)))
            
            checkField(calldataload(add(_pubSignals, 1056)))
            
            checkField(calldataload(add(_pubSignals, 1088)))
            
            checkField(calldataload(add(_pubSignals, 1120)))
            
            checkField(calldataload(add(_pubSignals, 1152)))
            
            checkField(calldataload(add(_pubSignals, 1184)))
            
            checkField(calldataload(add(_pubSignals, 1216)))
            
            checkField(calldataload(add(_pubSignals, 1248)))
            
            checkField(calldataload(add(_pubSignals, 1280)))
            
            checkField(calldataload(add(_pubSignals, 1312)))
            
            checkField(calldataload(add(_pubSignals, 1344)))
            
            checkField(calldataload(add(_pubSignals, 1376)))
            
            checkField(calldataload(add(_pubSignals, 1408)))
            
            checkField(calldataload(add(_pubSignals, 1440)))
            
            checkField(calldataload(add(_pubSignals, 1472)))
            
            checkField(calldataload(add(_pubSignals, 1504)))
            
            checkField(calldataload(add(_pubSignals, 1536)))
            
            checkField(calldataload(add(_pubSignals, 1568)))
            
            checkField(calldataload(add(_pubSignals, 1600)))
            
            checkField(calldataload(add(_pubSignals, 1632)))
            
            checkField(calldataload(add(_pubSignals, 1664)))
            
            checkField(calldataload(add(_pubSignals, 1696)))
            
            checkField(calldataload(add(_pubSignals, 1728)))
            
            checkField(calldataload(add(_pubSignals, 1760)))
            
            checkField(calldataload(add(_pubSignals, 1792)))
            
            checkField(calldataload(add(_pubSignals, 1824)))
            
            checkField(calldataload(add(_pubSignals, 1856)))
            
            checkField(calldataload(add(_pubSignals, 1888)))
            
            checkField(calldataload(add(_pubSignals, 1920)))
            
            checkField(calldataload(add(_pubSignals, 1952)))
            
            checkField(calldataload(add(_pubSignals, 1984)))
            
            checkField(calldataload(add(_pubSignals, 2016)))
            
            checkField(calldataload(add(_pubSignals, 2048)))
            
            checkField(calldataload(add(_pubSignals, 2080)))
            
            checkField(calldataload(add(_pubSignals, 2112)))
            
            checkField(calldataload(add(_pubSignals, 2144)))
            
            checkField(calldataload(add(_pubSignals, 2176)))
            
            checkField(calldataload(add(_pubSignals, 2208)))
            
            checkField(calldataload(add(_pubSignals, 2240)))
            
            checkField(calldataload(add(_pubSignals, 2272)))
            
            checkField(calldataload(add(_pubSignals, 2304)))
            
            checkField(calldataload(add(_pubSignals, 2336)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
