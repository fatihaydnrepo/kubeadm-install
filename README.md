# kubeadm-install

Bu repoda bulunan scriptleri `chmod +x k8s-install.sh` ile çalıştırılabilir hale getirip,  
`sudo ./k8s-install.sh` komutuyla kubeadm kurulumu yapabilirsiniz.

---

## Worker Node'da Alınan Hata

Eğer aşağıdaki hatayı alırsanız:

![image](https://github.com/user-attachments/assets/bd853e75-5e9c-4c34-9a20-e9c18edeb803)



### Bu Hata Ne Anlama Geliyor?

`kubectl` komutu API server’a bağlanmaya çalışıyor ama bulamıyor.  
Bunun sebebi, `kubectl`'in `~/.kube/config` dosyasını bulamaması veya içeriğinin doğru olmamasıdır.  
Bu yüzden varsayılan olarak `localhost:8080` adresine gitmeye çalışıyor ve orada API server bulunamadığı için bağlantı reddediliyor.

---

## Çözüm

Master node’da aşağıdaki komutları çalıştırarak `admin.conf` dosyasını kullanıcı dizinine kopyalayıp, izinleri ayarlayın:

Ardından tekrar deneyin:
kubectl get nodes


![image](https://github.com/user-attachments/assets/c8cb44fa-5b3c-4e7a-85f0-350d3f4a66fc)

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

