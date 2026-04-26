Gas 成本與 Kurtosis 可執行性實驗說明書
一、實驗目標
本實驗旨在評估本研究所提出之 P2P 能源交易清算機制，在單一交易回合中於鏈上執行「帳單驗證」與「清算撥款」所需之 Gas 成本，並進一步驗證該智慧合約流程能否部署並運行於較接近真實 Ethereum 節點架構的本地測試網環境中。
本研究架構中，DSO 會在鏈下彙整交易資料、智慧電表量測資料與價格資料，完成帳單清算並產生零知識證明；智慧合約則在鏈上驗證該 ZKP proof，並於驗證通過後執行清算與撥款流程。
因此，本實驗主要回答以下兩個問題：
在固定賣家數量的情境下，當系統處理 n 筆交易時，智慧合約在鏈上驗證帳單正確性與執行清算撥款需要消耗多少 Gas？
本研究之 Verifier.sol 與 Settlement.sol 是否能在較接近真實 Ethereum 節點架構的本地 testnet 中正常部署、驗證 proof，並完成清算流程？
本實驗不測量 DSO 鏈下計算帳單的時間，也不測量鏈下產生 ZKP proof 的 Gas，因為 Gas 只會發生於智慧合約在區塊鏈上執行交易時。

二、實驗環境與工具定位
本實驗使用 Kurtosis 建立本地 Ethereum testnet，並使用 Hardhat 進行 Solidity 合約編譯、部署、測試與 Gas 紀錄。
Kurtosis 的角色不是取代 Hardhat，而是負責建立一個較接近真實 Ethereum 節點架構的本地測試網。Kurtosis 官方文件說明，ethereum-package 可以啟動本地 Ethereum testnet，並可讓 Hardhat 連接該 testnet 來編譯、部署與測試 dApp；該套件可配置 execution layer client 與 consensus layer client，例如 geth、teku、lighthouse、lodestar 等。
因此，本實驗中兩者的分工如下：
工具
角色
Kurtosis
建立本地 Ethereum testnet，提供較接近真實節點架構的鏈上執行環境
Docker
承載 Kurtosis 啟動的 execution client、consensus client、validator、RPC 等服務
Hardhat
編譯 Solidity、部署 Verifier.sol 與 Settlement.sol、執行測試腳本、讀取 gasUsed
snarkjs / circom
產生 ZKP proof、public signals 與 Solidity verifier contract

本實驗的重點不是主張 Kurtosis 測得的 gas 一定比 Hardhat Network 更準，而是驗證本研究合約與 ZKP 清算流程在較接近真實 Ethereum client 架構的本地 testnet 中仍可正常運作。

三、實驗環境設計
1. Kurtosis 本地 Ethereum testnet
本研究使用 Kurtosis 啟動本地 Ethereum testnet。該 testnet 由 Docker containers 承載多個 Ethereum 相關服務，例如 execution client、consensus client、validator 與 RPC endpoint。
可使用以下方式啟動預設本地 Ethereum testnet：
kurtosis --enclave local-eth-testnet run github.com/ethpandaops/ethereum-package

若需要自訂 execution client 與 consensus client，可建立 network_params.yaml，例如：
participants:
  - el_type: geth
    cl_type: lighthouse

network_params:
  network_id: "12345"

再執行：
kurtosis run github.com/ethpandaops/ethereum-package --args-file ./network_params.yaml

Kurtosis 官方文件也說明，可透過設定檔自訂本地 Ethereum testnet 的節點組合，例如使用 geth、reth、lighthouse、teku 等 client。(Kurtosis 文檔)

2. Hardhat 與 Kurtosis 的連接方式
Kurtosis 啟動本地 testnet 後，會提供 RPC endpoint。Hardhat 不再使用內建的 Hardhat Network，而是透過 hardhat.config.js 或 hardhat.config.ts 連接 Kurtosis 提供的 RPC。
概念如下：
Kurtosis 啟動本地 Ethereum testnet
        ↓
取得 RPC endpoint
        ↓
Hardhat 透過 RPC 連接 Kurtosis testnet
        ↓
部署 Verifier.sol 與 Settlement.sol
        ↓
呼叫 verifyBillOnly() 與 settle()
        ↓
記錄 transaction receipt 中的 gasUsed

Hardhat 官方文件也指出，部署時可以指定不同 network，例如 --network localhost 或其他自訂 network；若未指定 network，才會使用內建的 in-memory Hardhat Network。(Hardhat)
因此，本實驗的 Hardhat network 設定可改為：
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    version: "0.8.26",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    kurtosis: {
      url: "http://127.0.0.1:<KURTOSIS_RPC_PORT>",
      chainId: 12345,
      accounts: [
        "<PRIVATE_KEY_FROM_KURTOSIS_PREFUNDED_ACCOUNT>"
      ]
    }
  }
};

其中：
<KURTOSIS_RPC_PORT>

需要替換為 Kurtosis 輸出的 RPC port。

四、ZKP 電路與 Verifier 合約
本研究需先完成帳單驗證電路，例如：
BillCircuit.circom

該電路需驗證：
1. 輸入資料是否與 commitment / hash 對應
2. 買方付款金額是否計算正確
3. 賣方應收金額是否計算正確
4. DSO 差額是否計算正確
5. 公開輸入與私有 witness 是否滿足清算規則

接著使用 snarkjs 產生：
proof.json
public.json
Verifier.sol

其中：
檔案
用途
proof.json
鏈下產生的 ZKP proof
public.json
傳給智慧合約的 public signals
Verifier.sol
由 snarkjs 產生的 Solidity 驗證合約

需要注意的是：
ZKP proof 是鏈下產生的，智慧合約只負責驗證 proof，不負責產生 proof。

五、智慧合約設計
本研究至少需要兩個合約：
1. Verifier.sol
2. Settlement.sol

Verifier.sol 用來驗證 ZKP proof。
Settlement.sol 是主合約，負責呼叫 verifier，並在驗證通過後執行撥款或狀態更新。
建議在 Settlement.sol 中設計兩個主要函式：
function verifyBillOnly(...) external returns (bool);

以及：
function settle(...) external;

兩者用途如下：
函式
用途
verifyBillOnly()
只測 ZKP 驗證 Gas
settle()
測 ZKP 驗證通過後，加上清算撥款的總 Gas


六、實驗情境設計
本實驗以「單一交易回合」為單位。
一個交易回合可定義為：
固定 3 位賣家，系統處理 n 筆交易後，由 DSO 產生一筆帳單清算結果與 ZKP proof，並提交至智慧合約驗證。若驗證通過，智慧合約撥款給 3 位賣家。
固定條件
賣家數量：3
交易回合：1 回合
清算者：DSO
鏈上執行者：Settlement 智慧合約
ZKP 類型：Groth16 / zkSNARK
合約測試工具：Hardhat
本地 Ethereum testnet：Kurtosis ethereum-package
Execution client：geth 或 reth
Consensus client：lighthouse 或 teku
EVM / hardfork：建議與比較文獻或目標環境一致，例如 Cancun
Solidity compiler：0.8.26

變動條件
交易筆數 n

建議先測：
n = 3, 6, 9, 12, 15, 30

若電路與 proof 產生流程穩定，再擴充到：
n = 60, 90, 120


七、實驗指標
本實驗最後至少需要測得以下 Gas 指標。
1. Gas_verify_success
意義：ZKP 驗證通過時的 Gas 成本。
測試方式：
使用正確 proof 與正確 public signals 呼叫 verifyBillOnly()

紀錄：
transaction receipt 中的 gasUsed

這個數值代表：
智慧合約確認帳單清算結果正確所需的鏈上成本。

2. Gas_verify_fail
意義：ZKP 驗證失敗時的 Gas 成本。
測試方式：
將 proof 或 public signals 故意改錯，再呼叫 verifyBillOnly()

例如：
1. 修改 publicSignals[0]
2. 修改某個付款金額
3. 使用不對應的 proof

這筆交易應該會 revert 或回傳 false。
紀錄：
失敗交易 receipt 中的 gasUsed

這個數值代表：
智慧合約拒絕錯誤帳單或錯誤 proof 所需的鏈上成本。

3. Gas_settlement_success
意義：ZKP 驗證通過後，完成清算撥款的總 Gas。
測試方式：
使用正確 proof 與正確 public signals 呼叫 settle()

settle() 內部應包含：
1. 驗證 ZKP proof
2. 驗證通過後更新 3 位賣家的餘額
3. 記錄清算結果
4. emit event

這個數值代表：
單一回合中，智慧合約完成帳單驗證與清算撥款的總鏈上成本。

4. Gas_payout_only
意義：撥款與狀態更新本身的額外 Gas。
計算方式：
Gas_payout_only = Gas_settlement_success - Gas_verify_success

這個數值代表：
扣除 ZKP 驗證後，單純執行賣家撥款與狀態更新所需的額外成本。

5. Gas_deploy_verifier
意義：部署 Verifier.sol 所需 Gas。
紀錄：
Verifier.sol deployment receipt.gasUsed

這可作為系統初始化成本，也可與 Jiang et al. 文獻中 reported verifier deployment gas 比較。

6. Gas_deploy_settlement
意義：部署 Settlement.sol 所需 Gas。
紀錄：
Settlement.sol deployment receipt.gasUsed


7. Kurtosis_execution_result
除了 gas 數值，本實驗新增一項「可執行性驗證」結果。
紀錄：
項目
結果
Kurtosis testnet 是否成功啟動
Pass / Fail
Hardhat 是否成功連接 Kurtosis RPC
Pass / Fail
Verifier.sol 是否成功部署
Pass / Fail
Settlement.sol 是否成功部署
Pass / Fail
valid proof 是否成功驗證
Pass / Fail
invalid proof 是否被拒絕
Pass / Fail
settle() 是否成功完成狀態更新
Pass / Fail
是否成功取得交易 receipt 與 gasUsed
Pass / Fail

這個表格用來支撐論文中的「較接近真實 Ethereum 節點架構下可執行」主張。

八、實驗結果表格設計
表 1：Kurtosis testnet 可執行性驗證
測試項目
結果
說明
Kurtosis testnet 啟動


成功建立本地 Ethereum testnet
RPC endpoint 可連線


Hardhat 可透過 RPC 連接 testnet
Verifier.sol 部署


取得合約地址
Settlement.sol 部署


取得合約地址
valid proof 驗證


verifyBillOnly() 回傳 true 或交易成功
invalid proof 拒絕


revert 或回傳 false
settlement 執行


settle() 成功更新狀態並 emit event
gasUsed 取得


每筆交易 receipt 可讀取 gasUsed


表 2：Kurtosis 環境下 Gas 實驗結果
賣家數
交易數 n
Gas_verify_success
Gas_verify_fail
Gas_settlement_success
Gas_payout_only
3
3








3
6








3
9








3
12








3
15








3
30










表 3：合約部署成本
合約
Gas
Verifier.sol


Settlement.sol


Total deployment gas




表 4：Hardhat Network 與 Kurtosis testnet 比較，選做
如果你想更完整，可以用 Hardhat Network 跑一組 baseline，再用 Kurtosis 跑一組可執行性驗證。
環境
Gas_verify_success
Gas_settlement_success
差異說明
Hardhat Network




開發用本地鏈
Kurtosis Ethereum testnet




較接近真實節點架構

分析時可以這樣寫：
若兩者 gasUsed 差異不大，表示本研究鏈上成本主要由合約 bytecode、EVM hardfork、calldata、storage 狀態與函式邏輯決定，而非 Hardhat 特定執行環境造成。若兩者有差異，則需檢查 Solidity compiler、optimizer、EVM hardfork、初始狀態與 calldata 是否完全一致。

十、比較分析方法
1. Kurtosis 可執行性分析
本研究可先說明：
本研究使用 Kurtosis 建立本地 Ethereum testnet，並透過 Hardhat 連接該 testnet 完成 Verifier.sol 與 Settlement.sol 的部署、ZKP proof verification、invalid proof rejection 與 settlement execution。實驗結果顯示，本研究智慧合約流程不僅可於開發用本地鏈執行，也可於較接近真實 Ethereum 節點架構的本地 testnet 中正常運作。

2. Gas 穩定性分析
若 Gas_verify_success 隨 n 增加仍接近固定，可寫：
實驗結果顯示，當交易數 n 增加時，Gas_verify_success 未呈現明顯線性成長，表示本研究並未將 n 筆交易逐筆放入鏈上處理，而是透過鏈下清算與單一 ZKP proof 將帳單正確性轉化為固定成本的鏈上驗證問題。
若 Gas_settlement_success 也接近固定，可寫：
由於賣家數量固定，settle() 中的撥款與狀態更新次數固定，因此 Gas_payout_only 與 Gas_settlement_success 亦應維持相對穩定。這代表本研究適合用於大量交易後的批次清算場景。

3. 與 Jiang et al. 比較：ZKP 驗證成本
比較：
本研究 Gas_verify_success
vs.
Jiang et al. proof verification gas

分析重點：
方法
ZKP 驗證內容
Jiang et al.
驗證 aggregated report 可信性
本研究
驗證帳單清算、付款金額、賣方應收金額與 DSO 差額正確性

可寫：
若本研究 Gas_verify_success 隨 n 增加仍維持近似固定，代表本研究能像 Jiang et al. 一樣，將大量交易資料聚合成單一 proof 進行鏈上驗證。差異在於，Jiang et al. 主要驗證 aggregated report 的可信性，而本研究進一步將驗證結果連接至智慧合約清算撥款流程。

4. 與 PriVET 比較：清算撥款成本
不建議直接比較：
本研究 Gas_settlement_success
vs.
PriVET settle gas

因為本研究的 Gas_settlement_success 包含：
ZKP 驗證 + 撥款

PriVET 的 settle() 較接近：
seller fund transfer

因此較公平的比較是：
本研究 Gas_payout_only
vs.
PriVET settle gas

可寫：
PriVET 的 settle() 主要反映資金轉移成本，而本研究完整 settle() 同時包含 ZKP 驗證與賣家撥款。為避免比較基準不一致，本研究將 Gas_settlement_success 扣除 Gas_verify_success，得到 Gas_payout_only，用以對照 PriVET 的 settlement 成本。

十一、論文可主張的重點
1. 本研究可在較接近真實 Ethereum 節點架構下執行
本研究不僅於 Hardhat 開發環境中完成合約測試，亦使用 Kurtosis 建立本地 Ethereum testnet，並透過 Hardhat 連接該 testnet 部署與執行智慧合約。實驗結果可用以支持本研究之 ZKP 驗證與清算撥款流程具備在 Ethereum-like 節點架構下執行的可行性。
2. 本研究鏈上成本集中於 ZKP 驗證與固定賣家撥款
本研究不在鏈上逐筆計算 n 筆交易帳單，而是透過 ZKP 將帳單正確性轉化為鏈上可驗證條件。因此，鏈上成本主要來自 proof verification 與固定賣家集合的撥款，而非逐筆交易計算。
3. 本研究比鏈上匹配型方法更適合批次清算
相較於 PriVET 將 encrypted matching 放入智慧合約，本研究將交易清算放在鏈下進行，並以 ZKP 驗證清算正確性，因此當交易筆數增加時，可避免鏈上逐筆處理交易資料所造成的 Gas 成長。
4. 本研究比單純 aggregated report verification 多了自動撥款能力
相較於 Jiang et al. 主要使用 zkSNARK/NIZK 驗證 aggregated report，本研究進一步將驗證結果與智慧合約撥款流程結合，使系統能在 proof 驗證通過後自動完成清算與賣家收益分配。

十二、整體流程總結
修改後的整體流程如下：
建立 Hardhat 專案
↓
撰寫帳單驗證 ZKP 電路
↓
產生 proof、public signals、Verifier.sol
↓
撰寫 Settlement.sol
↓
使用 Kurtosis 啟動本地 Ethereum testnet
↓
取得 Kurtosis RPC endpoint 與 prefunded account
↓
設定 Hardhat network 連接 Kurtosis RPC
↓
部署 Verifier.sol 與 Settlement.sol 到 Kurtosis testnet
↓
記錄 Gas_deploy_verifier 與 Gas_deploy_settlement
↓
用 valid proof 測 Gas_verify_success
↓
用 invalid proof 測 Gas_verify_fail
↓
用 valid proof 呼叫 settle() 測 Gas_settlement_success
↓
計算 Gas_payout_only
↓
改變 n，重複測量
↓
整理 gas 表格、可執行性驗證表與折線圖
↓
與 PriVET、Jiang et al. 分層比較


