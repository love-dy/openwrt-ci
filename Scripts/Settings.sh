#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" $CFG_FILE
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" $CFG_FILE

if [[ $WRT_URL == *"lede"* ]]; then
	LEDE_FILE=$(find ./package/lean/autocore/ -type f -name "index.htm")
	#修改默认时间格式
	sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S %A")/g' $LEDE_FILE
	#添加编译日期标识
	sed -i "s/(\(<%=pcdata(ver.luciversion)%>\))/\1 \/ $WRT_REPO-$WRT_DATE/g" $LEDE_FILE
	#修改默认WIFI名
	sed -i "s/ssid=.*/ssid=$WRT_WIFI/g" ./package/kernel/mac80211/files/lib/wifi/mac80211.sh
else
	#修改默认WIFI名
	sed -i "s/ssid=.*/ssid='$WRT_WIFI'/g" $(find ./package/network/config/wifi-scripts/files/lib/wifi/ -type f -name "mac80211.*")
	#修改immortalwrt.lan关联IP
	sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
	#添加编译日期标识
	sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_REPO-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")
	#替换chinadns-ng/Makefile
	mv -f ../Patches/chinadns-ng/Makefile ./feeds/packages/net/chinadns-ng/
fi

#默认主题修改
#echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
#echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#添加主题
echo "CONFIG_PACKAGE_luci-theme-design=y" >> .config
echo "CONFIG_PACKAGE_luci-app-design-config=y" >> .config
echo "CONFIG_PACKAGE_luci-theme-argon=y" >> .config
echo "CONFIG_PACKAGE_luci-app-argon-config=y" >> .config

#添加科学上网插件
if [[ $WRT_URL == *"lede"* ]]; then
	echo "CONFIG_PACKAGE_luci-app-passwall=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Hysteria=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_NaiveProxy=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_tuic_client=y" >> ./.config
	
	echo "CONFIG_PACKAGE_luci-app-ssr-plus=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Hysteria=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Tuic_Client=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_NaiveProxy=y" >> ./.config
	
	echo "CONFIG_PACKAGE_luci-app-openclash=y" >> ./.config	
else
	echo "CONFIG_PACKAGE_luci=y" >> ./.config
	echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-homeproxy=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-mihomo=y" >> ./.config
fi

