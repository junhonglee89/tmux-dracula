#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

fahrenheit=$1
location=$2

display_location()
{
	if $location; then
#		city=$(curl -s https://ipinfo.io/city 2> /dev/null)
#		region=$(curl -s https://ipinfo.io/region 2> /dev/null)
        city=$(curl -sL wttr.in\?format=%l |awk '{print $1}' | awk -F'[, ]' '{print $1}')
        region=$(curl -sL wttr.in\?format=%l |awk '{print $2}' | awk -F'[, ]' '{print $1}')
#		echo " $city, $region"
		echo ''
	else
		echo ''
	fi
}

fetch_weather_information()
{
	display_weather=$1
	# it gets the weather condition textual name (%C), and the temperature (%t)
	curl -sL wttr.in\?format="%C+%t$display_weather"
}

#get weather display
display_weather()
{
	if $fahrenheit; then
		display_weather='&u' # for USA system
	else
		display_weather='&m' # for metric system
	fi
	weather_information=$(fetch_weather_information $display_weather)

	weather_condition=$(echo $weather_information | rev | cut -d ' ' -f2- | rev) # Sunny, Snow, etc
	temperature=$(echo $weather_information | rev | cut -d ' ' -f 1 | rev) # +31°C, -3°F, etc
	unicode=$(forecast_unicode $weather_condition)

#	echo "$unicode${temperature/+/}" # remove the plus sign to the temperature
    unicode=$(curl -sL wttr.in\?format=%c |awk '{print $1}')
    temperature=$(curl -sL wttr.in\?format="%t&m" |awk '{print $1}')
    RH=$(curl -sL wttr.in\?format="%h&m" |awk '{print $1}')
    wind=$(curl -sL wttr.in\?format="%w&m" |awk '{print $1}')
    precipitation=$(curl -sL wttr.in\?format="%p&m" |awk '{print $1}')
    pressure=$(curl -sL wttr.in\?format="%P&m" |awk '{print $1}')
    moon=$(curl -sL wttr.in\?format="%m&m" |awk '{print $1}')
#    city=$(curl -sL wttr.in\?format=%l |awk '{print $1}' | awk -F'[, ]' '{print $1}')
#    region=$(curl -sL wttr.in\?format=%l |awk '{print $2}' | awk -F'[, ]' '{print $1}')
    city=$(curl https://freegeoip.app/csv/ | cut -d, -f"6")
    region=$(curl https://freegeoip.app/csv/ | cut -d, -f"3")

    echo  "$unicode  ${temperature/+/} $city $region"
#    echo  "$unicode  ${temperature/+/} $RH $wind $precipitation $moon   $city, $region"
}

forecast_unicode()
{
	weather_condition=$(echo $weather_condition | awk '{print tolower($0)}')

	if [[ $weather_condition =~ 'snow' ]]; then
		echo '☃️  '
	elif [[ $weather_condition =~ 'rain' ]]; then
		echo '☔️  '
    elif [[ $weather_condition =~ 'shower' ]]; then
		echo '⚡️  '
	elif [[ $weather_condition =~ 'overcast' ]]; then
		echo '☁️  '
    elif [[ $weather_condition =~ 'cloud' ]]; then
		echo '⛅️  '
	elif [[ $weather_condition = 'NA' ]]; then
		echo '? '
	else
		echo '☀️  '
	fi
}

main()
{
	# process should be cancelled when session is killed
	if ping -q -c 1 -W 1 ipinfo.io &>/dev/null; then
		echo "$(display_weather)$(display_location)"
	else
		echo "Location Unavailable"
	fi
}

#run main driver program
main
