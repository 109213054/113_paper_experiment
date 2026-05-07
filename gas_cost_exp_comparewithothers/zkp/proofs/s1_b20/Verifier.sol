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
    uint256 constant deltax1 = 15890039142363832481355965656944428125302712287219648113447345613177081120756;
    uint256 constant deltax2 = 2867458854764829708198619901988833466224195788722269306827240508547307037474;
    uint256 constant deltay1 = 1611063385924920352431711936989849755251276755897102634325089919871508593792;
    uint256 constant deltay2 = 6313489219400441970399351984647204246858747703686353576187613796368513308996;

    
    uint256 constant IC0x = 6268672432243618464796101987963940302651811570834248179939444713075586759200;
    uint256 constant IC0y = 3167695769188704282148611129414776691580317047985964234753836632739844114998;
    
    uint256 constant IC1x = 21631387778857304408063235949296898420345492374013376453983414305864505616143;
    uint256 constant IC1y = 10257157238661868063827163199299511594036271271404334081274586572092186619933;
    
    uint256 constant IC2x = 13640887777372543708619072706318792244783857357819144486903463271306169496012;
    uint256 constant IC2y = 21636174804809668015041885956436641028359292663107252611823778398989806208992;
    
    uint256 constant IC3x = 6731893387313297500567654776989995050370554455594202698983581841023999059911;
    uint256 constant IC3y = 2351762420739262307822752050286820058890884818132892093657190156896400721592;
    
    uint256 constant IC4x = 17929182956186070863259096128374584375968759944741395318994471438807528885616;
    uint256 constant IC4y = 5182056615842539114265163939837329533689867717810233254409453049502413909156;
    
    uint256 constant IC5x = 11580719238314699201468793159020312576042436901485181942812481853831323555031;
    uint256 constant IC5y = 20671972458021413694583844366513783123871267262690757663012787262337403367688;
    
    uint256 constant IC6x = 11911948341308129107611004253904714578875135261151070423871739388751184358332;
    uint256 constant IC6y = 2829337024840507949372760994925988244171919604671077952503257824248096664341;
    
    uint256 constant IC7x = 661681942997088403278660265084892665750057825153896020589812463372670875566;
    uint256 constant IC7y = 12992123542324019137613686761822403066480904129687328369561782902250375706655;
    
    uint256 constant IC8x = 4800105783797389338806312013374902663625804375207019710679345817330829200582;
    uint256 constant IC8y = 7776603445728712474451934259016944700953968593727014654014328531368903252214;
    
    uint256 constant IC9x = 14461653542043211091601245809341980811587176439496118690363056153134143287841;
    uint256 constant IC9y = 17011097936259910673101896948560129335398593453726356593033759220953615936404;
    
    uint256 constant IC10x = 18555905437624241784578836492616450796934592618815859097102319476245624421420;
    uint256 constant IC10y = 10110772107417386164373843611076172160237708343639272962095248805083691491994;
    
    uint256 constant IC11x = 5993103107399051848988861238617970339758964958464832773037592195023491842885;
    uint256 constant IC11y = 2790847147785955354582751297915507024656319659581102592976310425658531631266;
    
    uint256 constant IC12x = 6742368273160551958614059587066978243508443810029031366365528697208274178548;
    uint256 constant IC12y = 10326773613525376573594405953662831896884432908878800136764214525383296518650;
    
    uint256 constant IC13x = 8253049545196138588283710794206488598990971698854812856739770017780730911011;
    uint256 constant IC13y = 2238145369811668102493601442818232013059691853179245623439069145406068420302;
    
    uint256 constant IC14x = 4341836966849491562416251802390075139171930238669850764571326796531543030145;
    uint256 constant IC14y = 7980722118832418553887821210602199341633902222507483389226572921505981886890;
    
    uint256 constant IC15x = 5375066047567091455359991502124744402542076835407205471204161287292677119520;
    uint256 constant IC15y = 4128543047775016862520468182482565387278350664814391234283777186364309775747;
    
    uint256 constant IC16x = 15162128918958939983879632708305353235937227556850102576079607333842794946707;
    uint256 constant IC16y = 10751823511279128886960159648846624438415617134757637612047572947989641126436;
    
    uint256 constant IC17x = 2220786943035269703545625772707541727984750299227884522638891717787089077145;
    uint256 constant IC17y = 15840748980125925971559592153962062890581735251130104530028384925686487792242;
    
    uint256 constant IC18x = 7689034417137285050957425287564934608827828652687290466516249410140529011634;
    uint256 constant IC18y = 11853726703134432360473384759795688575675804412466731854990564408768779176979;
    
    uint256 constant IC19x = 15729792635190454705548564590106365922999121614259138909634817576288149784382;
    uint256 constant IC19y = 15946576706738865732233119012675115307537408887192923053336998356641801728799;
    
    uint256 constant IC20x = 7031879302117193463711334544138756040008991318829182913891507429998265992818;
    uint256 constant IC20y = 2817257295920515323630841957430100842556494793740585005709234513221026056847;
    
    uint256 constant IC21x = 10293854213255451353392817058508448239057923454858402475884428427119443805595;
    uint256 constant IC21y = 11424754095055670600631475523847785766178731152353888565029815189798116344778;
    
    uint256 constant IC22x = 18493290608376061076807302965675678626941768434014376288140571251465089236721;
    uint256 constant IC22y = 7306097869359537832917746757280105764896944497605338292593212293139360679495;
    
    uint256 constant IC23x = 3678896954536398850731486841603091531245628461317548713182763031789445454219;
    uint256 constant IC23y = 18738240633944355299351092921707124223354740883751167540094315904561832423269;
    
    uint256 constant IC24x = 12839896510602971887790870645274682466322229625334413493521458178019263032384;
    uint256 constant IC24y = 20703979740678270337739492816600089059808066245026929822602595232470058241110;
    
    uint256 constant IC25x = 767267524617228375744374473272702377294055462177346183151704143858351796487;
    uint256 constant IC25y = 129748552509022045927234630579490371855456498819281498515195520215907951859;
    
    uint256 constant IC26x = 20783552821736455319705935403745032989694909707998090643726160039561660238518;
    uint256 constant IC26y = 1161767325413111377225970567509874225429960457561070925016892005399084983150;
    
    uint256 constant IC27x = 15981321655913344780161522349510673789484364292499689092010951059682316602792;
    uint256 constant IC27y = 10662814974468269978167686608592638386795793409620908557091340521462127587532;
    
    uint256 constant IC28x = 12918409196995473223745111393570425233670601804409015321362978808387796483722;
    uint256 constant IC28y = 18884698546644870293400883739087400427980577433306662619279339824652353915517;
    
    uint256 constant IC29x = 18074294408780619412304164260670915153765882485188019600915904224240677967237;
    uint256 constant IC29y = 4196057618801201605537280084229725220386886824907945812678217202837717192165;
    
    uint256 constant IC30x = 12313082997045354737274231342767055446126491549735806854984499929683059748591;
    uint256 constant IC30y = 1078407117846192161853834780628797817589977107104373972548163491289136451704;
    
    uint256 constant IC31x = 18439659744325772626372603950165562721358840538161097696300568861183178482029;
    uint256 constant IC31y = 16748910903937743456524924744399259323318004108282364161106343651124030542585;
    
    uint256 constant IC32x = 17267192691330893482218439708434928172491576803852140089533431956857796057477;
    uint256 constant IC32y = 7215141234344021196522190567181836044105616542001021474148259578061742467308;
    
    uint256 constant IC33x = 13548522375868161923010763172746799379954858358583356851040882769770782289610;
    uint256 constant IC33y = 8389238935888282165458092556820852836641221354517463248081185771274927289641;
    
    uint256 constant IC34x = 864246215585340280484543554586606053539273526679750946709032570461634915366;
    uint256 constant IC34y = 8677966227337597067315858599256113401609736370605073648227642079321046193922;
    
    uint256 constant IC35x = 7997052209355942599919960285259011038855145541930704692675440137130392704584;
    uint256 constant IC35y = 13909616069276360420317211940888891462339038464192581662684219474501491697055;
    
    uint256 constant IC36x = 21097901615046746903404491975907078148875292951221360244957423661935130332466;
    uint256 constant IC36y = 2525634763166676068565694657246733738807052520576762713758984579088406185982;
    
    uint256 constant IC37x = 12530479306434685931112467357375758787445502193525988986816266412213653148478;
    uint256 constant IC37y = 10042081967609948188213026326302849644308044337819526216049017370405478856227;
    
    uint256 constant IC38x = 16015440420596595677260279383252035610354450331893319448773085135810931605968;
    uint256 constant IC38y = 11371810575766815084543598505558981623794214643537850588784988605891013440474;
    
    uint256 constant IC39x = 4553157558926913253499983529863651408462259236826437292604780856754837334513;
    uint256 constant IC39y = 21255972683526233745496747085639367445956277079263465615974610386634365253144;
    
    uint256 constant IC40x = 10868538591577514589388091689990641268907855049925741591454394486910304497902;
    uint256 constant IC40y = 2853887128110109874800107216021744422110866664710340042420641868796592862836;
    
    uint256 constant IC41x = 16469981669267913811770834234702210008045410353265154918551452725158424875810;
    uint256 constant IC41y = 12542232084414421991487995488241934216257116337211092654219298223162262422206;
    
    uint256 constant IC42x = 7655004630039211642816216304317641541177618909147997872051076791852726267976;
    uint256 constant IC42y = 736235712029069725661545382296334236763429773011887315516105428128464077770;
    
    uint256 constant IC43x = 20034813284455148425400599142286222712646617626266140238733063656756877377663;
    uint256 constant IC43y = 679684330528932411847130490276304152017963771849403833916756445066305350051;
    
    uint256 constant IC44x = 636422232997967821323136704382683160378925530583595722990774853824061263379;
    uint256 constant IC44y = 20897822070409108935688559663879510697711450278939494827717098744478584181265;
    
    uint256 constant IC45x = 21802317882777261520694983493691271996685216010352657105411388073524126083007;
    uint256 constant IC45y = 20516587894571383630158630859885824408459077733151406347246795341268177552238;
    
    uint256 constant IC46x = 13648202955439164140936824196736783109649045970671904098236578397778108637692;
    uint256 constant IC46y = 14139852338897106580085416623690256359027957059807394358209422394330689580283;
    
    uint256 constant IC47x = 18248316387304102425145489345644514305475247077170805348740106587993514276320;
    uint256 constant IC47y = 6228457270852202863151600782586282371015140815936188181276087370185629301867;
    
    uint256 constant IC48x = 15357791795083734047970239945463964777693528721124019566598123249812140194156;
    uint256 constant IC48y = 12702429073959097345761521996837521842513584506479658802396571527753593831723;
    
    uint256 constant IC49x = 5008171676430225533023546999287012304560475599526173662959640739788073206557;
    uint256 constant IC49y = 6317445528054986955649679025334215144232959101784785729373085588887924180989;
    
    uint256 constant IC50x = 12197028479239837653423041317647621552189348370587953246708365593679643786177;
    uint256 constant IC50y = 6366551146937463895378747661749086427817092927148032894003168682508957200473;
    
    uint256 constant IC51x = 846428970513477450576435980616015976603007011242824536708676926795987960038;
    uint256 constant IC51y = 6889932515008840993997801287349536761801462086621275673815397985489648405125;
    
    uint256 constant IC52x = 3287318801973221292349301961847596593053839471224700001425509887509520929822;
    uint256 constant IC52y = 13100221467373062633810453397974504536714336908683350668240810747995574157182;
    
    uint256 constant IC53x = 19237863172706399871010144765472741098731509428814871294396616886877317754663;
    uint256 constant IC53y = 19931608551253469260254749122625254650866677578368592485350240033745619244080;
    
    uint256 constant IC54x = 19712783137968233361879108403987468238560153759276282125543669430158041154397;
    uint256 constant IC54y = 5206887561434996259813526931543950627662246116885986658939373733465641258398;
    
    uint256 constant IC55x = 5177548056814022848066905128725764292128809485449549210817728013781785389250;
    uint256 constant IC55y = 586684311728788493742109110582125710346441487713266642344753547220030134004;
    
    uint256 constant IC56x = 17950569919711506569849620721850375479662314313127250773229978310532126977255;
    uint256 constant IC56y = 19191075452908896415923801817185217790140018612475205274145310930114469984918;
    
    uint256 constant IC57x = 17719039403452037064875371597760111609235314351596326420698608181707408770384;
    uint256 constant IC57y = 1699784651844440459773690463415866568618900762457908205549149193913299774922;
    
    uint256 constant IC58x = 9965378617724211486674025189018651222385484827959377390693150175685482961898;
    uint256 constant IC58y = 4215003751274726256989636595455001346452472151620403233331585702294979438657;
    
    uint256 constant IC59x = 15492413993214053242309132447218343409702009603118139975861582572550551900613;
    uint256 constant IC59y = 14594252185462391115106062010454110487799088199832413632351868212183136425676;
    
    uint256 constant IC60x = 7875694675240913962054157895191526573109712025468773327247593158817768676410;
    uint256 constant IC60y = 12766216825178436473929745870605099832768078086330468794037062451773052685585;
    
    uint256 constant IC61x = 11613417154375320421843437579831976124785160532493150342781279988194897782543;
    uint256 constant IC61y = 8244583522552601404265921511982350538054445077601952389780976024712951340242;
    
    uint256 constant IC62x = 2532326139784989633233428006863939414302944887313780387692382512463410729852;
    uint256 constant IC62y = 1333913998282161086008459751297166348024166408014834355960143228500433202651;
    
    uint256 constant IC63x = 7645056780672488348369589686920156206971717312273240533371537516925070418623;
    uint256 constant IC63y = 20069142259180188941293893557825501470041775729223010360597350077686327883336;
    
    uint256 constant IC64x = 16960876874523189839283598324983619377744014632570856061191583079795966729909;
    uint256 constant IC64y = 17192370936074872855402339847760207222876517774561187980129658950078936355477;
    
    uint256 constant IC65x = 3205954910372538165204659755718952061671196258017504038516645260018492419602;
    uint256 constant IC65y = 12729082707911403369209564270817015065540776065450789532717855518761087713963;
    
    uint256 constant IC66x = 1611044049667127882787771760957119482207442276398598569317667293353051616236;
    uint256 constant IC66y = 13735152396024340838268128779024520846794460143959232210929584147917142221549;
    
    uint256 constant IC67x = 6785393090198954269028883400552141533948344371329198028013067956130817184729;
    uint256 constant IC67y = 17416568121726686334152824652325745051030366354247300496901631150047494831493;
    
    uint256 constant IC68x = 21451565365436283387160961473298274752619340383489367421240428007555801534287;
    uint256 constant IC68y = 20699408179968180215530405293398936320173645826505613882766997894670237204959;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[68] calldata _pubSignals) public view returns (bool) {
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
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
